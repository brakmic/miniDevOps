#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "krew version reports" {
    run kubectl krew version
    assert_success
}
