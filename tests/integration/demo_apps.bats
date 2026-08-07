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
}

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
