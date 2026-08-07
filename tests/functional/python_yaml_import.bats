#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "python3 can import yaml" {
    run python3 -c 'import yaml; print(yaml.__version__)'
    assert_success
}
