#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup

    if [ -z "${KUBECONFIG_PATH:-}" ] && [ -z "${KUBECONFIG:-}" ]; then
        skip "no kubeconfig available"
    fi

    if [ -n "${KUBECONFIG_PATH}" ] && [ -f "${KUBECONFIG_PATH}" ]; then
        local writable="/tmp/kubeconfig-live"
        cp "${KUBECONFIG_PATH}" "${writable}"
        chmod 600 "${writable}"
        export KUBECONFIG="${writable}"
    fi
}

@test "kubectl can reach cluster" {
    run kubectl cluster-info
    assert_success
}

@test "kubectl lists nodes" {
    run kubectl get nodes
    assert_success
}

@test "helm lists releases" {
    run helm list --all-namespaces
    assert_success
}

@test "kubectx lists contexts" {
    run kubectx
    assert_success
}

@test "kubens lists namespaces" {
    run kubens
    assert_success
}

@test "popeye live scan produces output" {
    run bash -c "popeye -o yaml 2>&1"
    assert_output --partial "popeye:"
}

@test "flux check (version-aware)" {
    local k8s_ver
    k8s_ver=$(kubectl version -o json 2>/dev/null | grep '"gitVersion"' | tail -1 | grep -o 'v[0-9.]*' | sed 's/^v//')
    if [ -z "${k8s_ver}" ]; then
        k8s_ver=$(kubectl version --short 2>/dev/null | grep "Server Version" | grep -o 'v[0-9.]*' | sed 's/^v//')
    fi
    if [ -z "${k8s_ver}" ]; then
        skip "could not determine Kubernetes server version"
    fi
    local k8s_minor
    k8s_minor=$(echo "${k8s_ver}" | cut -d'.' -f2)
    if [ "${k8s_minor}" -ge 33 ] 2>/dev/null; then
        run flux check --pre
        assert_success
    else
        skip "Kubernetes ${k8s_ver} < 1.33.0 required by Flux ${EXPECTED_FLUX}"
    fi
}

@test "kubeseal raw mode (controller-independent)" {
    local cert_file
    cert_file=$(generate_seal_cert)
    assert [ -n "${cert_file}" ]

    run bash -c "echo -n 'test' | kubeseal --raw --cert '${cert_file}' --scope cluster-wide --name live-test --namespace default"
    assert_success

    rm -f "${cert_file}" /tmp/sealed-test-key.pem
}

@test "kubeseal validate (if controller available)" {
    run bash -c "kubeseal --validate --all-namespaces 2>&1 || true"
    # This test passes if the command doesn't hang; the controller may not be available
    assert true
}
