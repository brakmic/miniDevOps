#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "stern version reports" {
    run stern --version
    assert_success
}
