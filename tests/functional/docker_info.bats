#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "docker --version succeeds" {
    run docker --version
    assert_success
    assert_output --partial "Docker version"
}
