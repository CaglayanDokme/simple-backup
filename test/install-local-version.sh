#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

install_dir="${TEST_DIR}/bin"
symlink_path="${install_dir}/bkp"
expected_version="$(current_repo_version)"
versioned_path="${install_dir}/bkp-${expected_version}"

INSTALL_DIR="${install_dir}" bash "${DEV_INSTALL_SCRIPT}"

# Versioned binary exists and is executable
[[ -x "${versioned_path}" ]]

# Symlink exists and points to the versioned binary
[[ -L "${symlink_path}" ]]
[[ "$(readlink "${symlink_path}")" == "bkp-${expected_version}" ]]

# Version is correctly embedded
[[ "$("${versioned_path}" --version)" == "${expected_version}" ]]

# Placeholder is fully replaced
if grep -q '@@VERSION@@' "${versioned_path}"; then
    exit 1
fi

pass_test "Local install embeds version"