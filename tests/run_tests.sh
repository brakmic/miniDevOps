#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBECONFIG_PATH="${HOME}/.kube/config"
MODE="all"
REPORT_FORMAT="tap"
DRY_RUN=false
KEEP_CLUSTER=false

usage() {
    cat <<EOF
Usage: run_tests.sh [OPTIONS]

Options:
  --all                  Run all tiers in order (default)
  --tier <name>          Run specific tier: smoke, functional, integration, live
  --tool <name>          Run all tests matching tool name across all tiers
  --report <format>      Output format: tap (default), junit, pretty
  --dry-run              List tests without executing
  --kubeconfig <path>    Path to kubeconfig for live tier
  --keep-cluster         Do not destroy Kind cluster after integration tests

Examples:
  run_tests.sh --all
  run_tests.sh --tier functional
  run_tests.sh --tool kubeseal --report junit
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all) MODE="all"; shift ;;
        --tier) MODE="$2"; shift 2 ;;
        --tool) MODE="tool"; TOOL_FILTER="$2"; shift 2 ;;
        --report) REPORT_FORMAT="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --kubeconfig) KUBECONFIG_PATH="$2"; shift 2 ;;
        --keep-cluster) KEEP_CLUSTER=true; shift ;;
        --help|-h) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

bats_cmd() {
    local bats_args=("-r")
    case "${REPORT_FORMAT}" in
        junit) bats_args+=("--formatter" "junit") ;;
        tap) bats_args+=("--formatter" "tap") ;;
        pretty) ;; # default
    esac
    bats_args+=("$@")
    bats "${bats_args[@]}"
}

run_tier() {
    local tier="$1"
    local test_dir="${SCRIPT_DIR}/${tier}"
    if [ ! -d "${test_dir}" ]; then
        echo "Error: test directory ${test_dir} not found" >&2
        exit 1
    fi

    echo ""
    echo "=== Tier: ${tier} ==="
    echo ""

    if [ "${DRY_RUN}" = true ]; then
        echo "Dry run: would run bats -r ${test_dir}"
        return
    fi

    if [ "${tier}" = "live" ] && [ -n "${KUBECONFIG_PATH}" ] && [ -f "${KUBECONFIG_PATH}" ]; then
        export KUBECONFIG_PATH
    fi

    bats_cmd "${test_dir}"
}

main() {
    echo "miniDevOps Test Suite v2"
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""

    case "${MODE}" in
        all)
            run_tier "smoke"
            run_tier "functional"
            run_tier "integration"
            if [ -f "${KUBECONFIG_PATH}" ]; then
                run_tier "live"
            else
                echo "Skipping live tier: no kubeconfig at ${KUBECONFIG_PATH}"
            fi
            ;;
        tool)
            echo "Tool filter not yet implemented. Use --tier instead."
            exit 1
            ;;
        *)
            run_tier "${MODE}"
            ;;
    esac

    echo ""
    echo "Test suite complete."
}

main
