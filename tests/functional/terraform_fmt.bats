#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "terraform fmt -check passes on valid .tf" {
    run terraform fmt -check "${SCRIPT_DIR}/tests/fixtures/"
    assert_success
}
