#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

install_dir="${TEST_DIR}/bin"
installed_script="${install_dir}/bkp"
expected_version="$(current_repo_version)"

INSTALL_DIR="${install_dir}" bash "${INSTALL_SCRIPT}"

[[ -x "${installed_script}" ]]
[[ "$("${installed_script}" --version)" == "${expected_version}" ]]

if grep -q '@@VERSION@@' "${installed_script}"; then
    exit 1
fi

pass_test "Local install embeds version"