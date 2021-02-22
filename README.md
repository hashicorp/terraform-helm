# Terraform Cloud Operator Helm Chart

This repository contains the official HashiCorp Helm chart for installing
and configuring the Terraform Cloud Operator on Kubernetes. This chart supports multiple use
cases of Terraform on Kubernetes depending on the values provided.

This chart is hosted on the official [HashiCorp helm chart repository](https://helm.releases.hashicorp.com).

## Prerequisites

To use the charts here, [Helm](https://helm.sh/) must be installed in your
Kubernetes cluster. Setting up Kubernetes and Helm and is outside the scope
of this README. Please refer to the Kubernetes and Helm documentation.

The versions required are:

  * **Helm +3.0.1** - This is the earliest version of Helm tested. It is possible
    it works with earlier versions but this chart is untested for those versions.
  * **Kubernetes 1.15+** - This is the earliest version of Kubernetes tested.
    It is possible that this chart works with earlier versions but it is
    untested.

In addition to Helm, you must also have a:

  * **Terraform Cloud organization** - Create an organization on Terraform
    Cloud/Enterprise.
  * **Terraform Cloud Team API Token** - Generate a
    [team API token](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) for the
    Terraform Cloud organization you want to use. Make sure the team at least
    has privileges to manage workspaces.

## Usage

Before installing the chart, you must create two Kubernetes secrets:

1. `credentials` file contents with Terraform Cloud Team API token. See
   [Terraform Cloud Configuration File Syntax](https://www.terraform.io/docs/commands/cli-config.html)
   for proper format.
   ```shell
   $ kubectl -n $NAMESPACE create secret generic terraformrc --from-file=credentials
   ```

1. Sensitive variables for a workspace.
   ```shell
   $ kubectl -n $NAMESPACE create secret generic workspacesecrets --from-literal=secret_key=abc123
   ```

 To use the charts, you must add the HashiCorp Helm Chart repository.

```shell
$ helm repo add hashicorp https://helm.releases.hashicorp.com
$ helm search repo hashicorp/terraform
$ helm install --namespace ${RELEASE_NAMESPACE} hashicorp/terraform --generate-name
```
```
NAME               	CHART VERSION	APP VERSION	DESCRIPTION
hashicorp/terraform	1.0  	           	Install and configure Terraform Cloud Operator ...
```

```
NAME: terraform-1589480669
LAST DEPLOYED: Thu May 14 11:24:32 2020
NAMESPACE: operator
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Terraform Cloud Operator!

Now that you have deployed HashiCorp Terraform Cloud Operator, you should look over the docs on using
Terraform with Kubernetes available here:

https://github.com/hashicorp/terraform-k8s/blob/master/README.md


Your release is named terraform-1589480669. To learn more about the release, try:

  $ helm status terraform-1589480669
  $ helm get terraform-1589480669
```
    

Please see the many options supported in the `values.yaml`
file.

To create a Terraform workspace, you can create a separate Helm chart to deploy
the custom resource or examine the example under `example/`. Helm does not currently
support a `wait` function before deletion, which will cause custom resources to remain
behind.

Note that the Helm chart automatically installs all Custom Resource Definitions under
the `crds/` directory. As a result, any updates to the schema must be manually copied into
the directory and removed from the Kubernetes cluster:

```shell
$ kubectl delete crd workspaces.app.terraform.io
```

If the CRD is not updated correctly, you will not be able to create a Workspace Custom Resource.
