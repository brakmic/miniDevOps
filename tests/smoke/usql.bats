#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "usql version reports" {
    run usql --version
    assert_success
}
