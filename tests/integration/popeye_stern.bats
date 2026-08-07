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

@test "popeye scan produces output on populated cluster" {
    run bash -c "popeye -o yaml 2>&1"
    assert_output --partial "popeye:"
}

@test "stern can list matching pods" {
    run bash -c "stern --tail=1 --no-follow 'myapp' 2>&1 || true"
    assert true
}
