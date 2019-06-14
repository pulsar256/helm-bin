# HELM Binary

Wraps the helm binary and preconfigures the runtime environment with a 
sevice user for a given kubernetes api server.

Initial motivation: to be used as a part of a CI/CD pipeline, ideally within (but not restricted to) the cluster.

Any arbitrary version of helm and kubectl are supported and will be dowloaded upon execution. Pre-Cached versions of both tools can be baked into the image (see building)

## Environment Parameters

- `HELM_VERSION`
  `helm` version to use, example `v2.14.1`
- `KUBECTL_VERSION`
  `kubectl` version to use, example `1.14.3`
- `KUBE_MASTER`
  k8s api server endpoint, see `kubectl cluster-info`
- `KUBE_TOKEN`
  service user auth token
- `SKIP_TLS_VERIFY` default: false
  affects `insecure-skip-tls-verify`, provide `KUBE_CA` if set to `false`
- `KUBE_CA`
  k8s cluster CA

## Building

use default build configuration or override the helm and kubectl versions:

```bash
docker build \
    --build-arg helm_version="v2.14.1" \
    --build-arg kubectl_version="v1.14.3" \
    .
```

## Usage

```bash
docker run \
    -e HELM_VERSION="v2.14.1" \
    -e KUBECTL_VERSION="v1.14.3" \
    -e KUBE_MASTER=$KUBE_MASTER \
    -e KUBE_TOKEN=$KUBE_TOKEN \
    -e KUBE_CA=$KUBE_CA \
    pulsar256/helm-bin ls
```
