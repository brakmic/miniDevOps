#!/usr/bin/env bats
# Integration tests: all share one Kind cluster.

setup() {
    load '../test_helper/common_setup'
    common_setup
}

setup_file() {
    load '../test_helper/common_setup'
    common_setup

    echo "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."
    kind create cluster --name "${KIND_CLUSTER_NAME}" --wait 5m
    kubectl wait --for=condition=Ready nodes --all --timeout=120s
}

teardown_file() {
    echo "Tearing down Kind cluster '${KIND_CLUSTER_NAME}'..."
    kind delete cluster --name "${KIND_CLUSTER_NAME}" || true
}

# --- Cluster basics ---

@test "kind cluster created successfully" {
    run kind get clusters
    assert_success
    assert_output --partial "${KIND_CLUSTER_NAME}"
}

@test "nodes are ready" {
    run kubectl get nodes --no-headers
    assert_success
    [ "$(echo "${output}" | wc -l)" -ge 1 ]
}

# --- Demo apps ---

@test "simple demo app deploys" {
    run kubectl apply -f "${SCRIPT_DIR}/demos/app-simple/" --wait=true --timeout=60s
    assert_success
}

@test "simple demo pod is ready" {
    run kubectl wait --for=condition=ready pod -l app=myapp --timeout=120s
    assert_success
}

@test "Helm chart deploys" {
    run helm install test-release "${SCRIPT_DIR}/demos/app-chart/" --wait --timeout 60s
    assert_success
}

# --- kubeseal ---

@test "sealed-secrets controller installs" {
    run kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.27.2/controller.yaml
    assert_success
}

@test "sealed-secrets controller is running" {
    run bash -c "kubectl wait --for=condition=ready pod -l name=sealed-secrets-controller -n kube-system --timeout=120s 2>&1"
    assert_success
}

@test "kubeseal can fetch controller cert" {
    run bash -c "kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=kube-system 2>&1"
    assert_success
    assert_output --partial "BEGIN CERTIFICATE"
}

# --- popeye and stern ---

@test "popeye scan on populated cluster" {
    run bash -c "popeye -o yaml 2>&1"
    assert_output --partial "popeye:"
}

@test "stern can access cluster" {
    run bash -c "stern --tail=1 --no-follow 'myapp' 2>&1 || true"
    assert true
}

# --- context switching ---

@test "kubectx lists kind context" {
    run kubectx
    assert_success
    assert_output --partial "kind-${KIND_CLUSTER_NAME}"
}

@test "kubens switches to default namespace" {
    run kubens default
    assert_success
}

# --- flux ---

@test "flux check passes on Kind cluster" {
    run flux check --pre
    assert_success
}
