# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# name_prefix returns the prefix of the resources within Kubernetes.
name_prefix() {
    printf "terraform"
}

# helm_install installs the Terraform chart. This will source overridable
# values from the "values.yaml" file in this directory. This can be set
# by CI or other environments to do test-specific overrides. Note that its
# easily possible to break tests this way so be careful.
helm_install() {
    if test -f "${TF_CLI_CONFIG_FILE}"; then
        kubectl create secret generic terraformrc --from-file=credentials=${TF_CLI_CONFIG_FILE}
    else
        kubectl create secret generic terraformrc --from-file=credentials=${HOME}/.terraformrc
    fi

    kubectl create secret generic workspacesecrets 

    local values="${BATS_TEST_DIRNAME}/values.yaml"
    if [ ! -f "${values}" ]; then
        touch $values
    fi

    helm install -f ${values} terraform --wait ${BATS_TEST_DIRNAME}/../..
}

# helm_delete deletes the Terraform chart and all resources.
helm_delete() {
    kubectl delete workspace terraform-terraform-test --ignore-not-found
    helm del terraform
    kubectl delete secret terraformrc
    kubectl delete secret workspacesecrets
}

# wait for a pod to be ready
wait_for_ready() {
    POD_NAME=$1

    check() {
        # This requests the pod and checks whether the status is running
        # and the ready state is true. If so, it outputs the name. Otherwise
        # it outputs empty. Therefore, to check for success, check for nonzero
        # string length.
        kubectl get pods $1 -o json | \
            jq -r 'select(
                .status.phase == "Running" and
                ([ .status.conditions[] | select(.type == "Ready" and .status == "True") ] | length) == 1
            ) | .metadata.namespace + "/" + .metadata.name'
    }

    for i in $(seq 30); do
        if [ -n "$(check ${POD_NAME})" ]; then
            echo "${POD_NAME} is ready."
            return
        fi

        echo "Waiting for ${POD_NAME} to be ready..."
        sleep 2
    done

    echo "${POD_NAME} never became ready."
    exit 1
}