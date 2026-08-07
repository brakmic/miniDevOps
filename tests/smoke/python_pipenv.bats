#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "python3 is available" {
    run python3 --version
    assert_success
}

@test "pipenv is available" {
    run pipenv --version
    assert_success
}
