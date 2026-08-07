#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "flux version is ${EXPECTED_FLUX}" {
    run flux --version
    assert_success
    assert_output --partial "${EXPECTED_FLUX}"
}
