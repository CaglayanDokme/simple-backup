#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

install_dir="${TEST_DIR}/bin"
symlink_path="${install_dir}/bkp"
expected_version="$(current_repo_version)"
versioned_path="${install_dir}/bkp-${expected_version}"

# --- First install ---
INSTALL_DIR="${install_dir}" bash "${DEV_INSTALL_SCRIPT}"

# Symlink points to the versioned binary
[[ -L "${symlink_path}" ]]
[[ "$(readlink "${symlink_path}")" == "bkp-${expected_version}" ]]
[[ -x "${versioned_path}" ]]

# --- Simulate a second version by copying with a fake version name ---
fake_version="v99.99.99"
fake_versioned_path="${install_dir}/bkp-${fake_version}"
cp "${versioned_path}" "${fake_versioned_path}"
chmod +x "${fake_versioned_path}"

# Update symlink to the fake version (mimics a second install)
ln -sf "bkp-${fake_version}" "${symlink_path}"

[[ "$(readlink "${symlink_path}")" == "bkp-${fake_version}" ]]

# --- Verify old version is still present ---
[[ -x "${versioned_path}" ]]

# --- Re-install original version, symlink should switch back ---
INSTALL_DIR="${install_dir}" bash "${DEV_INSTALL_SCRIPT}"

[[ "$(readlink "${symlink_path}")" == "bkp-${expected_version}" ]]

# Both versioned files still exist
[[ -x "${versioned_path}" ]]
[[ -x "${fake_versioned_path}" ]]

pass_test "Symlink install preserves old versions"
