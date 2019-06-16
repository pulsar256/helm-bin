#!/bin/bash

function downloadHelm {
    version=$1
    if [ ! -f "$HOME/.local/lib/helm-${version}/helm" ]; then 
        echo "cached helm version ${version} not found. Installing..."
        curl http://storage.googleapis.com/kubernetes-helm/helm-${version}-linux-amd64.tar.gz > /tmp/helm-${version}.tar.gz
        mkdir -p $HOME/.local/lib/helm-${version}/
        tar -C $HOME/.local/lib/helm-${version}/ -xvf /tmp/helm-${version}.tar.gz --strip 1
        rm $HOME/.local/lib/helm-${version}/tiller
        upx $HOME/.local/lib/helm-${version}/helm
    fi
}  

function downloadKubectl {
    version=$1
    if [ ! -f "$HOME/.local/lib/kubectl-${version}/kubectl" ]; then 
        echo "cached kubectl version ${version} not found. Installing..."
        mkdir -p $HOME/.local/lib/kubectl-${version}/
        curl https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubectl > $HOME/.local/lib/kubectl-${version}/kubectl
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
