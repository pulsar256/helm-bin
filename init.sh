#!/bin/bash

source ./functions.sh
         
requireEnvVar "${HELM_VERSION}" "HELM_VERSION is not set"
requireEnvVar "${KUBECTL_VERSION}" "KUBECTL_VERSION is not set"
requireEnvVar "${KUBE_MASTER}" "KUBE_MASTER is not set"
requireEnvVar "${KUBE_TOKEN}" "KUBE_TOKEN is not set"
SKIP_TLS_VERIFY=${SKIP_TLS_VERIFY:-false}

if [[ $SKIP_TLS_VERIFY -eq "false" ]]; then
    requireEnvVar "${KUBE_CA}" "KUBE_CA is not set"
fi
echo SKIP_TLS_VERIFY $SKIP_TLS_VERIFY

downloadHelm $HELM_VERSION
ln -s -f $HOME/.local/lib/helm-${HELM_VERSION}/helm $HOME/.local/bin/helm

downloadKubectl $KUBECTL_VERSION
ln -s -f $HOME/.local/lib/kubectl-${KUBECTL_VERSION}/kubectl $HOME/.local/bin/kubectl

export PATH=$HOME/.local/bin:$PATH

echo "generating kube config"

cat > $HOME/kubeconfig <<EOF
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
    namespace: devops
  name: helm

preferences: {}

users:
  - name: user
    user:
      token: ${KUBE_TOKEN}
EOF

export KUBECONFIG=$HOME/kubeconfig

echo "Using helm $(which helm)"
echo "Using kubectl $(which kubectl)"

helm version    || error "Helm installation is not functional"
kubectl version || error "Kubectl installation is not functional"

helm "$@"
