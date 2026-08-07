#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubectx is available" {
    run kubectx --help
    assert_success
}

@test "kubens is available" {
    run kubens --help
    assert_success
}
