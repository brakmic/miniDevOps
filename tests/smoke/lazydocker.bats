#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "lazydocker version reports" {
    run lazydocker --version
    assert_success
}
