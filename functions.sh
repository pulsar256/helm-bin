#!/bin/bash

function downloadHelm {
    version=$1
    if [ ! -f "$HOME/.local/lib/helm-${version}/helm" ]; then 
        dlurl="https://get.helm.sh/helm-${version}-linux-amd64.tar.gz"
        echo "cached helm version ${version} not found. Installing from $dlurl ..."
        curl ${dlurl} > /tmp/helm-${version}.tar.gz || exit 
        mkdir -p $HOME/.local/lib/helm-${version}/
        tar -C $HOME/.local/lib/helm-${version}/ -xvf /tmp/helm-${version}.tar.gz --strip 1 || exit
        upx $HOME/.local/lib/helm-${version}/helm
    fi
}  

function downloadKubectl {
    version=$1
    if [ ! -f "$HOME/.local/lib/kubectl-${version}/kubectl" ]; then 
        dlurl="https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubectl"
        echo "cached kubectl version ${version} not found. Installing from ${dlurl} ..."
        mkdir -p $HOME/.local/lib/kubectl-${version}/
        curl ${dlurl} > $HOME/.local/lib/kubectl-${version}/kubectl || exit
        chmod +x $HOME/.local/lib/kubectl-${version}/kubectl
        upx $HOME/.local/lib/kubectl-${version}/kubectl
    fi
}  

function requireEnvVar {
    if [ -z "${1}" ]; then
        echo "$2 is not set"
        exit 1
    fi  
}
