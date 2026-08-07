#!/usr/bin/env bats

setup_file() {
    load '../test_helper/common_setup'
    common_setup

    local waited=0
    while [ ! -f /tmp/kind-ready ] && [ ${waited} -lt 120 ]; do
        sleep 2
        waited=$((waited + 2))
    done
    [ -f /tmp/kind-ready ] || skip "Kind cluster not available"

    # Install sealed-secrets controller
    echo "Installing sealed-secrets controller..."
    kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.27.2/controller.yaml 2>/dev/null
    kubectl wait --for=condition=ready pod -l name=sealed-secrets-controller -n kube-system --timeout=120s 2>/dev/null || true
}

@test "sealed-secrets controller is running" {
    run kubectl get pods -l name=sealed-secrets-controller -n kube-system --no-headers
    assert_success
    assert_output --partial "Running"
}

@test "kubeseal can fetch controller cert" {
    run bash -c "kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=kube-system 2>&1"
    assert_success
    assert_output --partial "BEGIN CERTIFICATE"
}
