#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "operator-sdk version reports" {
    run operator-sdk version
    assert_success
}
