#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubecolor version reports Kubecolor Version" {
    run kubecolor version
    assert_output --partial "Kubecolor Version"
}
