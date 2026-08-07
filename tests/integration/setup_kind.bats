#!/usr/bin/env bats

setup_file() {
    load '../test_helper/common_setup'
    common_setup

    echo "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."
    kind create cluster --name "${KIND_CLUSTER_NAME}" --wait 5m
    kubectl wait --for=condition=Ready nodes --all --timeout=120s
    touch /tmp/kind-ready
}

teardown_file() {
    if [ -f /tmp/kind-ready ]; then
        echo "Tearing down Kind cluster '${KIND_CLUSTER_NAME}'..."
        kind delete cluster --name "${KIND_CLUSTER_NAME}" || true
        rm -f /tmp/kind-ready
    fi
}

@test "kind cluster is created" {
    [ -f /tmp/kind-ready ]
}

@test "nodes are ready" {
    run kubectl get nodes --no-headers
    assert_success
    [ "$(echo "${output}" | wc -l)" -ge 1 ]
}
