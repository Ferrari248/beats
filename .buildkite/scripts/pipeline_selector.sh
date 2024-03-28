#!/usr/bin/env bash
set -euo pipefail

heartbeat_changeset=(
  "^heartbeat/.*"
  )
auditbeat_changeset=(
  "^auditbeat/.*"
  )  
metricbeat_changeset=(
  "^metricbeat/.*"
  )

oss_changeset=(
  "^go.mod"
  "^pytest.ini"
  "^dev-tools/.*"
  "^libbeat/.*"
  "^testing/.*"
)

are_paths_changed() {
  local patterns=("${@}")
  local changelist=()
  for pattern in "${patterns[@]}"; do
    changed_files=($(git diff --name-only HEAD@{1} HEAD | grep -E "$pattern"))
    if [ "${#changed_files[@]}" -gt 0 ]; then
      changelist+=("${changed_files[@]}")
    fi
  done

  if [ "${#changelist[@]}" -gt 0 ]; then
    echo "Files changed:"
    echo "${changelist[*]}"
    return 0
  else
    echo "No files changed within specified changeset:"
    echo "${patterns[*]}"
    return 1
  fi
}

if [[ are_paths_changed "${heartbeat_changeset[@]}" || are_paths_changed "${oss_changeset}" ]]; then
  buildkite-agent pipeline upload .buildkite/heartbeat/heartbeat-pipeline.yml
fi  

if [[ are_paths_changed "${auditbeat_changeset[@]}" || are_paths_changed "${oss_changeset}" ]]; then
  buildkite-agent pipeline upload .buildkite/heartbeat/heartbeat-pipeline.yml
fi

if [[ are_paths_changed "${metricbeat_changeset[@]}" || are_paths_changed "${oss_changeset}" ]]; then
  buildkite-agent pipeline upload .buildkite/heartbeat/heartbeat-pipeline.yml
fi

#......
## Packaging
packaging_changeset=(
  "^dev-tools/packaging/.*"
  ".go-version"
  )

if [[ are_paths_changed "${packaging_changeset[@]}" ]]; then
  buildkite-agent pipeline upload .buildkite/package-pipeline.yml
fi
