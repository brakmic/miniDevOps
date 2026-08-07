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

@test "flux check passes on Kind cluster" {
    run flux check --pre
    assert_success
}
