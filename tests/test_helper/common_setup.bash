#!/usr/bin/env bash

# Test Suite v2 — shared constants, helpers, and setup
#
# Sourced by every .bats file via:
#   setup() { load '../test_helper/common_setup'; common_setup; }

###############################################################################
# Expected versions (update when tools are bumped)
###############################################################################
export EXPECTED_KUBECTL="1.32.3"
export EXPECTED_FLUX="2.9.3"
export EXPECTED_HELM="4.2.3"
export EXPECTED_K9S="0.51.0"
export EXPECTED_KIND="0.32.0"
export EXPECTED_KUBELOGIN="0.2.19"
export EXPECTED_KUBESEAL="0.38.4"
export EXPECTED_OPERATOR_SDK="1.42.3"
export EXPECTED_SKAFFOLD="2.24.0"
export EXPECTED_STERN="1.34.0"
export EXPECTED_TERRAFORM="1.15.8"
export EXPECTED_YQ="4.53.3"

export KIND_CLUSTER_NAME="minidevops-test"
export SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"

###############################################################################
# Counters
###############################################################################
PASSED=0
FAILED=0
SKIPPED=0

###############################################################################
# Called from setup() in each .bats file
###############################################################################
common_setup() {
    local helper_dir
    helper_dir="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../test_helper" && pwd)"
    load "${helper_dir}/bats-support/load"
    load "${helper_dir}/bats-assert/load"
}

###############################################################################
# Convenience version checker (for smoke tests that don't use BATS asserts)
###############################################################################
check_version() {
    local tool="$1" expected="$2" actual="$3"
    if echo "${actual}" | grep -q "${expected}"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
        echo "FAIL: ${tool} version: expected ${expected}, got ${actual}" >&2
    fi
}

###############################################################################
# Kind cluster cleanup
###############################################################################
cleanup_kind() {
    if kind get clusters 2>/dev/null | grep -q "^${KIND_CLUSTER_NAME}$"; then
        echo "Cleaning up Kind cluster '${KIND_CLUSTER_NAME}'..."
        kind delete cluster --name "${KIND_CLUSTER_NAME}" || true
    fi
}

###############################################################################
# Generate a self-signed cert for kubeseal raw mode testing
###############################################################################
generate_seal_cert() {
    local cert_file="/tmp/sealed-test-cert.pem"
    local key_file="/tmp/sealed-test-key.pem"
    if ! openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "${key_file}" \
        -out "${cert_file}" \
        -subj "/CN=sealed-secrets-test" \
        -days 1 2>/dev/null; then
        return 1
    fi
    echo "${cert_file}"
}
