#!/usr/bin/env bats

load _helpers

@test "syncWorkspace/Role: enabled by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-role.yaml  \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Role: disabled with global.enabled=false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-role.yaml 
      --set 'global.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "syncWorkspace/Role: disabled with sync disabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-role.yaml  
      --set 'syncWorkspace.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "syncWorkspace/Role: enabled with sync enabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-role.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Role: enabled with sync enabled and global.enabled=false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-role.yaml  \
      --set 'global.enabled=false' \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -s 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}