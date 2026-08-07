#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kind version is ${EXPECTED_KIND}" {
    run kind version
    assert_success
    assert_output --partial "v${EXPECTED_KIND}"
}
