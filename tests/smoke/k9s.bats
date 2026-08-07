#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "k9s version is ${EXPECTED_K9S}" {
    run k9s version --short
    assert_success
    assert_output --partial "v${EXPECTED_K9S}"
}
