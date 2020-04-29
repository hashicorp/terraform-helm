#!/usr/bin/env bats

load _helpers

@test "syncWorkspace/RoleBinding: enabled by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-rolebinding.yaml  \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/RoleBinding: disabled with global.enabled=false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-rolebinding.yaml  \
      --set 'global.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "syncWorkspace/RoleBinding: disabled with sync disabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-rolebinding.yaml  \
      --set 'syncWorkspace.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "syncWorkspace/RoleBinding: enabled with sync enabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-rolebinding.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -s 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/RoleBinding: enabled with sync enabled and global.enabled=false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-rolebinding.yaml  \
      --set 'global.enabled=false' \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -s 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}
