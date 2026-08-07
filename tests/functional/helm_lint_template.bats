#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "helm lint validates demos/app-chart" {
    run helm lint "${SCRIPT_DIR}/demos/app-chart/"
    assert_success
}

@test "helm template renders demos/app-chart" {
    run helm template test "${SCRIPT_DIR}/demos/app-chart/"
    assert_success
    assert_output --partial "kind: Deployment"
}
