#!/usr/bin/env bats

load _helpers

@test "syncWorkspace/Deployment: enabled by default" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: enable with global.enabled false" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'global.enabled=false' \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: disable with syncWorkspace.enabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "syncWorkspace/Deployment: disable with global.enabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'global.enabled=false' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

#--------------------------------------------------------------------
# image

@test "syncWorkspace/Deployment: image defaults to global.imageK8S" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'global.imageK8S=bar' \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].image' | tee /dev/stderr)
  [ "${actual}" = "bar" ]
}

@test "syncWorkspace/Deployment: image can be overridden with syncWorkspace.image" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'global.imageK8S=foo' \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.image=bar' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].image' | tee /dev/stderr)
  [ "${actual}" = "bar" ]
}

#--------------------------------------------------------------------
# imagePullPolicy

@test "syncWorkspace/Deployment: imagePullPolicy defaults to IfNotPresent" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'global.imageK8S=bar' \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].imagePullPolicy' | tee /dev/stderr)
  [ "${actual}" = "IfNotPresent" ]
}

@test "syncWorkspace/Deployment: imagePullPolicy can be overridden with syncWorkspace.imagePullPolicy" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'global.imageK8S=foo' \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.imagePullPolicy=Never' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].imagePullPolicy' | tee /dev/stderr)
  [ "${actual}" = "Never" ]
}

#--------------------------------------------------------------------
# tfe address

@test "syncWorkspace/Deployment: tfe address defaults to blank string" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].env[4].value' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "syncWorkspace/Deployment: tfe address defaults to tfe.local" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.tfeAddress=https://tfe.local' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].env[4].value' | tee /dev/stderr)
  [ "${actual}" = "https://tfe.local" ]
}

#--------------------------------------------------------------------
# watch namespace

@test "syncWorkspace/Deployment: watch namespace defaults to release namespace" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].args | any(contains("--k8s-watch-namespace=default"))' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: watch namespace can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.k8WatchNamespace=dev' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].args | any(contains("-k8s-watch-namespace=dev"))' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

#--------------------------------------------------------------------
# terraform version

@test "syncWorkspace/Deployment: terraform version defaults to operator-compiled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].env | any(contains("TF_VERSION"))' | tee /dev/stderr)
  [ "${actual}" = "" ]
}

@test "syncWorkspace/Deployment: terraform version is TF_VERSION" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.terraformVersion=0.11.1' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].env[2].value == "0.11.1"' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

#--------------------------------------------------------------------
# serviceAccount

@test "syncWorkspace/Deployment: serviceAccount set when sync enabled" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq '.spec.template.spec.serviceAccountName | contains("sync-workspace")' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

#--------------------------------------------------------------------
# secretsMounts

@test "syncWorkspace/Deployment: add terraformrc secrets name" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq '.spec.template.spec.volumes[0].secret.secretName | contains("terraformrc")' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: add terraformrc secrets key" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq '.spec.template.spec.volumes[0].secret.items[0].key | contains("credentials")' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: terraformrc secrets variables can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.terraformRC.secretName=terraformfile' \
      . | tee /dev/stderr |
      yq '.spec.template.spec.volumes[0].secret.secretName | contains("terraformfile")' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: add workspace secrets variables" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      . | tee /dev/stderr |
      yq '.spec.template.spec.volumes[1].secret.secretName | contains("workspacesecrets")' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "syncWorkspace/Deployment: workspace secrets variables can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      --show-only templates/sync-workspace-deployment.yaml  \
      --set 'syncWorkspace.enabled=true' \
      --set 'syncWorkspace.sensitiveVariables.secretName=newsecrets' \
      . | tee /dev/stderr |
      yq '.spec.template.spec.volumes[1].secret.secretName | contains("newsecrets")' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}
