#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "docker daemon is reachable" {
    run docker --version
    assert_success
}

@test "docker compose is available" {
    run docker compose version
    assert_success
}
