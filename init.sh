#!/bin/bash

##
# * Generates kube config based on the passed environment variables
# * Downloads (if uncached) requested versions of helm and kubectl
# * delegates all passed parameters to the helm or kubectl binary:
#   - if called directly (init.sh): wraps helm binary
#   - if called via symlink: wraps kubectl or helm binary based on the symlink
#     name.

source /functions.sh

# validate configuration
requireEnvVar "${HELM_VERSION}" "HELM_VERSION is not set"
requireEnvVar "${KUBECTL_VERSION}" "KUBECTL_VERSION is not set"
requireEnvVar "${KUBE_MASTER}" "KUBE_MASTER is not set"
requireEnvVar "${KUBE_TOKEN}" "KUBE_TOKEN is not set"
SKIP_TLS_VERIFY=${SKIP_TLS_VERIFY:-false}

if [ "$SKIP_TLS_VERIFY" = "false" ]; then
  requireEnvVar "${KUBE_CA}" "KUBE_CA is not set"
  echo "$KUBE_CA" | base64 -d >/dev/null
  if [ $? -ne 0 ]; then
    # this is needed for drone.io + kubernetes-secrets integration.
    # if you map a drone.io secret to a kubernetes.io/service-account-token.data.ca.crt
    # kuberntes-secret, the base64 value of the certificate will be decoded
    # before it gets passed to the job environment. We need to revert this in
    # order to be able to build a valid kubeconfig
    echo "KUBE_CA does not seem to be base64 encoded. Re-Encoding..."
    KUBE_CA=$(echo "$KUBE_CA" | base64 | tr -d '\n')
  fi
fi

# download requested (if not previously prebaked) helm & kubectl binaries
downloadHelm "$HELM_VERSION"
HELM_BIN=$HOME/.local/lib/helm-${HELM_VERSION}/helm

downloadKubectl "$KUBECTL_VERSION"
KUBE_BIN=$HOME/.local/lib/kubectl-${KUBECTL_VERSION}/kubectl

# generate basic, service-account based kube config.
cat >$HOME/kubeconfig <<EOF
apiVersion: v1
kind: Config

current-context: "helm"

clusters:
- cluster:
    insecure-skip-tls-verify: ${SKIP_TLS_VERIFY}
    server: ${KUBE_MASTER}
    certificate-authority-data: ${KUBE_CA}
  name: helm

contexts:
- context:
    cluster: helm
    user: user
  name: helm

preferences: {}

users:
  - name: user
    user:
      token: ${KUBE_TOKEN}
EOF

# setup runtime environment and delegate execution to the requested binary.
command=$(basename "$0")

export KUBECONFIG=$HOME/kubeconfig

echo "Configured to use helm: $HELM_BIN"
echo ".............. kubectl: $KUBE_BIN"

if [ "$DEBUG" = "true" ]; then
  echo "#### DEBUG Kubectl: ###################################################"
  cat $KUBECONFIG
  echo "#### DEBUG Env: #######################################################"
  set
  echo "#### END DEBUG ########################################################"
fi

if [ "$command" = "helm" ]; then
  $HELM_BIN "$@"
elif [ "$command" = "kubectl" ]; then
  $KUBE_BIN "$@"
else
  # default to helm to match the intent of the image
  $HELM_BIN "$@"
fi
