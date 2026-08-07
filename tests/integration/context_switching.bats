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

@test "kubectx lists kind context" {
    run kubectx
    assert_success
    assert_output --partial "kind-${KIND_CLUSTER_NAME}"
}

@test "kubens switches to default namespace" {
    run kubens default
    assert_success
}
