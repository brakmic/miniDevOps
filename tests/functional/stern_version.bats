#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "stern --version reports version string" {
    run stern --version
    assert_success
    assert_output --partial "version:"
    assert_output --partial "${EXPECTED_STERN}"
}
