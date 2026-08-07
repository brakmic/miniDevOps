#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "popeye version reports correctly" {
    run popeye version
    assert_success
}
