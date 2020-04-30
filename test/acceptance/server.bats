#!/usr/bin/env bats

load _helpers

@test "operator: default, comes up healthy" {
  helm_install
  wait_for_ready $(kubectl get pods --selector "component=sync-workspace" -o jsonpath="{.items[0].metadata.name}")

  helm test terraform

  # Clean up
  helm_delete
}