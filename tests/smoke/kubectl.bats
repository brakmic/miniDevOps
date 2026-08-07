#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubectl version is ${EXPECTED_KUBECTL}" {
    run kubectl version --client -o json
    assert_success
    assert_output --partial "\"gitVersion\": \"v${EXPECTED_KUBECTL}\""
}
