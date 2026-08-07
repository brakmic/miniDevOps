#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubeseal version reports" {
    run kubeseal --version
    assert_success
}
