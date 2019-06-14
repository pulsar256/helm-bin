#!/bin/bash

function downloadHelm {
    HELM_VERSION=$1
    if [ ! -f "$HOME/.local/lib/helm-${HELM_VERSION}/helm" ]; then 
        echo "cached helm version ${HELM_VERSION} not found. Installing..."
        curl http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz > /tmp/helm-${HELM_VERSION}.tar.gz
        mkdir -p $HOME/.local/lib/helm-${HELM_VERSION}/
        tar -C $HOME/.local/lib/helm-${HELM_VERSION}/ -xvf /tmp/helm-${HELM_VERSION}.tar.gz --strip 1
    fi
}  

function downloadKubectl {
    KUBECTL_VERSION=$1
    if [ ! -f "$HOME/.local/lib/kubectl-${KUBECTL_VERSION}/kubectl" ]; then 
        echo "cached kubectl version ${KUBECTL_VERSION} not found. Installing..."
        mkdir -p $HOME/.local/lib/kubectl-${KUBECTL_VERSION}/
        curl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > $HOME/.local/lib/kubectl-${KUBECTL_VERSION}/kubectl
        chmod +x $HOME/.local/lib/kubectl-${KUBECTL_VERSION}/kubectl
    fi
}  

function requireEnvVar {
    if [ -z "${1}" ]; then
        echo "$2 is not set"
        exit 1
    fi  
}
