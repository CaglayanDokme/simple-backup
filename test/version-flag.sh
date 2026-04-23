#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

expected_version="$(current_repo_version)"

[[ "$(bash "${BKP_SCRIPT}" --version)" == "${expected_version}" ]]
[[ "$(bash "${BKP_SCRIPT}" -v)" == "${expected_version}" ]]

pass_test "Version flag"