#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "terraform version is ${EXPECTED_TERRAFORM}" {
    run terraform version -json
    assert_success
    assert_output --partial "\"terraform_version\": \"${EXPECTED_TERRAFORM}\""
}
