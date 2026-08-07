#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubelogin version reports" {
    run kubelogin --version
    assert_success
}
