#!/usr/bin/env bats

load _helpers

@test "testConfigMap/ConfigMap: enabled by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-configmap.yaml  \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "testConfigMap/ConfigMap: disabled when tests.enabled=false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/tests/test-configmap.yaml  \
      --set 'tests.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "testConfigMap/ConfigMap: contains terraform backend configuration" {
  cd `chart_dir`
  local actual=$(helm template operator \
      --show-only templates/tests/test-configmap.yaml  \
      . | tee /dev/stderr |
      yq -r '.data.backend | contains("organization = tf-operator") ' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}