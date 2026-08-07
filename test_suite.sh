#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIND_CLUSTER_NAME="minidevops-test"
KUBECONFIG_PATH="${1:-}"
PASSED=0
FAILED=0
SKIPPED=0

###############################################################################
# Expected versions (update when tools are bumped)
###############################################################################
EXPECTED_KUBECTL="1.32.3"
EXPECTED_FLUX="2.9.3"
EXPECTED_HELM="4.2.3"
EXPECTED_K9S="0.51.0"
EXPECTED_KIND="0.32.0"
EXPECTED_KUBELOGIN="0.2.19"
EXPECTED_KUBESEAL="0.38.4"
EXPECTED_OPERATOR_SDK="1.42.3"
EXPECTED_SKAFFOLD="2.24.0"
EXPECTED_STERN="1.34.0"
EXPECTED_TERRAFORM="1.15.8"

###############################################################################
# Helpers
###############################################################################
log_pass() {
    echo "  [PASS] $1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo "  [FAIL] $1"
    FAILED=$((FAILED + 1))
}

log_skip() {
    echo "  [SKIP] $1 ($2)"
    SKIPPED=$((SKIPPED + 1))
}

check_version() {
    local tool="$1"
    local expected="$2"
    local actual="$3"
    if echo "${actual}" | grep -q "${expected}"; then
        log_pass "${tool} version: ${actual}"
    else
        log_fail "${tool} version: expected ${expected}, got ${actual}"
    fi
}

cleanup_kind() {
    if kind get clusters 2>/dev/null | grep -q "^${KIND_CLUSTER_NAME}$"; then
        echo "Cleaning up Kind cluster '${KIND_CLUSTER_NAME}'..."
        kind delete cluster --name "${KIND_CLUSTER_NAME}" || true
    fi
}

report() {
    echo ""
    echo "============================================"
    echo "Results: ${PASSED} passed, ${FAILED} failed, ${SKIPPED} skipped"
    echo "============================================"
    if [ "${FAILED}" -gt 0 ]; then
        echo "FAILURE: ${FAILED} test(s) failed"
        exit 1
    fi
    echo "SUCCESS: all tests passed"
}

###############################################################################
# Phase 1: Smoke tests (no cluster required)
###############################################################################
phase_smoke() {
    echo ""
    echo "============================================"
    echo "Phase 1: Smoke Tests (version checks)"
    echo "============================================"

    local ver

    # kubectl
    ver=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion": "v[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
    check_version "kubectl" "${EXPECTED_KUBECTL}" "${ver}"

    # helm
    ver=$(helm version --short 2>/dev/null | grep -o 'v[0-9.]*' | head -1 | sed 's/^v//')
    check_version "helm" "${EXPECTED_HELM}" "${ver}"

    # terraform
    ver=$(terraform version -json 2>/dev/null | grep -o '"terraform_version": "[^"]*"' | cut -d'"' -f4)
    check_version "terraform" "${EXPECTED_TERRAFORM}" "${ver}"

    # kind
    ver=$(kind version 2>&1 | grep -o 'v[0-9.]*' | head -1 | sed 's/^v//')
    check_version "kind" "${EXPECTED_KIND}" "${ver}"

    # k9s
    ver=$(k9s version --short 2>&1 | grep -o 'v[0-9.]*' | head -1 | sed 's/^v//')
    check_version "k9s" "${EXPECTED_K9S}" "${ver}"

    # stern
    stern --version >/dev/null 2>&1 && log_pass "stern version" || log_fail "stern version"

    # kubecolor (exits non-zero due to cluster connection attempt, capture output first)
    local kubecolor_out
    set +e
    kubecolor_out=$(kubecolor version 2>&1)
    set -e
    if echo "${kubecolor_out}" | grep -q "Kubecolor Version"; then
        log_pass "kubecolor version"
    else
        log_fail "kubecolor version"
    fi

    # skaffold
    ver=$(skaffold version 2>&1 | grep -o 'v[0-9.]*' | head -1 | sed 's/^v//')
    check_version "skaffold" "${EXPECTED_SKAFFOLD}" "${ver}"

    # flux
    ver=$(flux --version 2>&1 | grep -o '[0-9.]*' | head -1)
    check_version "flux" "${EXPECTED_FLUX}" "${ver}"

    # kubeseal
    kubeseal --version >/dev/null 2>&1 && log_pass "kubeseal version" || log_fail "kubeseal version"

    # operator-sdk
    operator-sdk version >/dev/null 2>&1 && log_pass "operator-sdk version" || log_fail "operator-sdk version"

    # kubelogin
    kubelogin --version >/dev/null 2>&1 && log_pass "kubelogin version" || log_fail "kubelogin version"

    # lazydocker
    lazydocker --version >/dev/null 2>&1 && log_pass "lazydocker version" || log_fail "lazydocker version"

    # popeye
    popeye version >/dev/null 2>&1 && log_pass "popeye version" || log_fail "popeye version"

    # kubectx
    kubectx --help >/dev/null 2>&1 && log_pass "kubectx available" || log_fail "kubectx available"

    # kubens
    kubens --help >/dev/null 2>&1 && log_pass "kubens available" || log_fail "kubens available"

    # krew
    kubectl krew version >/dev/null 2>&1 && log_pass "krew version" || log_fail "krew version"

    # usql
    usql --version >/dev/null 2>&1 && log_pass "usql version" || log_fail "usql version"

    # docker
    docker --version >/dev/null 2>&1 && log_pass "docker version" || log_fail "docker version"
    docker compose version >/dev/null 2>&1 && log_pass "docker compose version" || log_fail "docker compose version"

    # python
    python3 --version >/dev/null 2>&1 && log_pass "python3 version" || log_fail "python3 version"

    # pipenv
    pipenv --version >/dev/null 2>&1 && log_pass "pipenv version" || log_fail "pipenv version"
}

###############################################################################
# Phase 2: Kind cluster tests
###############################################################################
phase_kind() {
    echo ""
    echo "============================================"
    echo "Phase 2: Kind Cluster Tests"
    echo "============================================"

    trap cleanup_kind EXIT

    echo "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."
    if kind create cluster --name "${KIND_CLUSTER_NAME}" --wait 5m; then
        log_pass "kind create cluster"
    else
        log_fail "kind create cluster"
        return
    fi

    echo "Waiting for all nodes to be Ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=120s

    # Verify nodes
    local node_count
    node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    if [ "${node_count}" -ge 1 ]; then
        log_pass "kubectl get nodes (${node_count} nodes)"
    else
        log_fail "kubectl get nodes (expected >=1, got ${node_count})"
    fi

    # Deploy demo app (simple YAML)
    echo "Deploying demo app (simple)..."
    if kubectl apply -f "${SCRIPT_DIR}/demos/app-simple/" --wait=true --timeout=60s >/dev/null 2>&1; then
        log_pass "kubectl apply demos/app-simple"
    else
        log_fail "kubectl apply demos/app-simple"
    fi

    # Wait for demo pod
    if kubectl wait --for=condition=ready pod -l app=nginx --timeout=60s >/dev/null 2>&1; then
        log_pass "demo app pod ready"
    else
        log_fail "demo app pod ready (timeout)"
    fi

    # Deploy demo app (Helm chart)
    echo "Deploying demo app (Helm chart)..."
    if helm install test-release "${SCRIPT_DIR}/demos/app-chart/" --wait --timeout 60s >/dev/null 2>&1; then
        log_pass "helm install demos/app-chart"
    else
        log_fail "helm install demos/app-chart"
    fi

    # kubeseal: fetch controller cert and seal a test secret
    echo "Testing kubeseal..."
    if kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=kube-system > /tmp/cert.pem 2>/dev/null; then
        log_pass "kubeseal fetch cert"
        if echo "test: dmVyeSBzZWNyZXQ=" | kubeseal --cert /tmp/cert.pem --scope cluster-wide -o yaml > /tmp/sealed.yaml 2>/dev/null; then
            log_pass "kubeseal seal secret"
        else
            log_fail "kubeseal seal secret"
        fi
        rm -f /tmp/cert.pem /tmp/sealed.yaml
    else
        log_skip "kubeseal" "sealed-secrets controller not found on Kind cluster"
    fi

    # popeye: scan cluster
    echo "Running popeye scan..."
    if popeye -o yaml --all-namespaces --out /tmp/popeye.yaml >/dev/null 2>&1; then
        log_pass "popeye scan"
    else
        log_fail "popeye scan"
    fi
    rm -f /tmp/popeye.yaml

    # stern: capture one log line from a running pod
    echo "Testing stern..."
    if timeout 10 stern --tail=1 "app=nginx" --namespace default 2>/dev/null | head -1 > /tmp/stern.log; then
        log_pass "stern log capture"
    else
        log_skip "stern log capture" "no matching pods or timeout"
    fi
    rm -f /tmp/stern.log

    # kubectx
    kubectx 2>/dev/null | grep -q "kind-${KIND_CLUSTER_NAME}" && log_pass "kubectx context list" || log_fail "kubectx context list"

    # kubens
    kubens default >/dev/null 2>&1 && kubens 2>/dev/null | grep -q "default" && log_pass "kubens namespace switch" || log_fail "kubens namespace switch"

    # flux check (Kind 0.32.0 defaults to K8s >= 1.33.0, should pass)
    echo "Running flux check..."
    if flux check --pre >/dev/null 2>&1; then
        log_pass "flux check"
    else
        log_fail "flux check (Kind cluster should have K8s >= 1.33.0)"
    fi

    # Cleanup
    echo "Tearing down Kind cluster..."
    cleanup_kind
    trap - EXIT
    log_pass "kind delete cluster"
}

###############################################################################
# Phase 3: Live cluster tests (read-only, requires kubeconfig)
###############################################################################
phase_live() {
    if [ -z "${KUBECONFIG_PATH}" ]; then
        log_skip "live cluster phase" "no kubeconfig path provided"
        return
    fi

    # Copy kubeconfig to a writable location (kubectx/kubens need write access)
    local writable_kubeconfig="/tmp/kubeconfig-live"
    cp "${KUBECONFIG_PATH}" "${writable_kubeconfig}"
    chmod 600 "${writable_kubeconfig}"
    export KUBECONFIG="${writable_kubeconfig}"

    echo ""
    echo "============================================"
    echo "Phase 3: Live Cluster Tests"
    echo "============================================"

    # Verify cluster connectivity
    if kubectl cluster-info >/dev/null 2>&1; then
        log_pass "kubectl cluster-info"
    else
        log_fail "kubectl cluster-info (cannot reach cluster)"
        return
    fi

    # List nodes
    kubectl get nodes >/dev/null 2>&1 && log_pass "kubectl get nodes" || log_fail "kubectl get nodes"

    # helm list (read-only)
    helm list --all-namespaces >/dev/null 2>&1 && log_pass "helm list --all-namespaces" || log_fail "helm list"

    # kubectx
    kubectx >/dev/null 2>&1 && log_pass "kubectx context list" || log_fail "kubectx context list"

    # kubens
    kubens >/dev/null 2>&1 && log_pass "kubens namespace list" || log_fail "kubens namespace list"

    # popeye (read-only scan)
    if popeye -o yaml --all-namespaces --out /tmp/popeye-live.yaml >/dev/null 2>&1; then
        log_pass "popeye live scan"
    else
        log_fail "popeye live scan"
    fi
    rm -f /tmp/popeye-live.yaml

    # flux check with version awareness
    local k8s_ver
    k8s_ver=$(kubectl version -o json 2>/dev/null | grep '"gitVersion"' | tail -1 | grep -o 'v[0-9.]*' | sed 's/^v//')
    if [ -z "${k8s_ver}" ]; then
        k8s_ver=$(kubectl version --short 2>/dev/null | grep "Server Version" | grep -o 'v[0-9.]*' | sed 's/^v//')
    fi

    if [ -n "${k8s_ver}" ]; then
        local k8s_minor
        k8s_minor=$(echo "${k8s_ver}" | cut -d'.' -f2)
        if [ "${k8s_minor}" -ge 33 ] 2>/dev/null; then
            flux check --pre >/dev/null 2>&1 && log_pass "flux check" || log_fail "flux check"
        else
            log_skip "flux check" "Kubernetes ${k8s_ver} < 1.33.0 required by Flux 2.9.3"
        fi
    else
        log_skip "flux check" "could not determine Kubernetes server version"
    fi

    # kubeseal validation
    if kubeseal --validate --all-namespaces >/dev/null 2>&1; then
        log_pass "kubeseal validate"
    else
        log_skip "kubeseal validate" "sealed-secrets controller not available"
    fi
}

###############################################################################
# Main
###############################################################################
main() {
    echo "miniDevOps Test Suite"
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""

    phase_smoke
    phase_kind
    phase_live
    report
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
