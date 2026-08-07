#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "helm version is ${EXPECTED_HELM}" {
    run helm version --short
    assert_success
    assert_output --partial "v${EXPECTED_HELM}"
}
