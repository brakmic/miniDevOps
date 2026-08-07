#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "yq version is ${EXPECTED_YQ}" {
    run yq --version
    assert_success
    assert_output --partial "${EXPECTED_YQ}"
}
