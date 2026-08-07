#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    common_setup
}

@test "kubeseal raw mode seals a value with self-signed cert" {
    local cert_file
    cert_file=$(generate_seal_cert)
    assert [ -n "${cert_file}" ]
    assert [ -f "${cert_file}" ]

    run bash -c "echo -n 'test-secret' | kubeseal --raw --cert '${cert_file}' --scope cluster-wide --name test-secret --namespace default"
    assert_success
    assert [ -n "${output}" ]

    rm -f "${cert_file}" /tmp/sealed-test-key.pem
}
