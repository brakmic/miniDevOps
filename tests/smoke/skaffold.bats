#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "skaffold version is ${EXPECTED_SKAFFOLD}" {
    run skaffold version
    assert_success
    assert_output --partial "v${EXPECTED_SKAFFOLD}"
}
