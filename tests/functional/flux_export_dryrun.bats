#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "flux install --export produces valid YAML" {
    run flux install --export
    assert_success
    assert_output --partial "apiVersion: v1"
    assert_output --partial "kind: Namespace"
}

@test "flux create source git --export produces GitRepository" {
    run flux create source git test-source --url=https://example.com/repo.git --branch=main --export
    assert_success
    assert_output --partial "GitRepository"
}
