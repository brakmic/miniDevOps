#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubectx --help exits 0" {
    run kubectx --help
    assert_success
}

@test "kubens --help exits 0" {
    run kubens --help
    assert_success
}
