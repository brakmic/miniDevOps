#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubectl options lists available flags" {
    run kubectl options
    assert_success
    assert_output --partial "--namespace"
}
