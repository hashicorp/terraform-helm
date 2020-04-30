#!/usr/bin/env bats

load _helpers

@test "testWorkspace/Workspace: enabled by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-workspace.yaml  \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "testWorkspace/Workspace: disabled when tests.enabled=false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-workspace.yaml  \
      --set 'tests.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "testWorkspace/Workspace: module source set to git by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-workspace.yaml  \
      . | tee /dev/stderr |
      yq -r '.spec.module.source' | tee /dev/stderr)
  [ "${actual}" = "git::https://github.com/hashicorp/terraform-helm.git//test/module" ]
}

@test "testWorkspace/Workspace: module source can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-workspace.yaml  \
      --set 'tests.moduleSource=hello/random' \
      . | tee /dev/stderr |
      yq -r '.spec.module.source' | tee /dev/stderr)
  [ "${actual}" = "hello/random" ]
}

@test "testWorkspace/Workspace: organization set by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-workspace.yaml  \
      . | tee /dev/stderr |
      yq -r '.spec.organization' | tee /dev/stderr)
  [ "${actual}" = "tf-operator" ]
}

@test "testWorkspace/Workspace: organization can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-workspace.yaml  \
      --set 'tests.organization=demo' \
      . | tee /dev/stderr |
      yq -r '.spec.organization' | tee /dev/stderr)
  [ "${actual}" = "demo" ]
}