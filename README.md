# HELM Binary

Wraps the helm, kubectl binary and preconfigures the runtime environment with a sevice user for a given kubernetes api server.

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
ᐅ docker build \
    --build-arg helm_version="v2.14.1" \
    --build-arg kubectl_version="v1.14.3" \
    .
```

## Usage

### Standalone
 
```bash
ᐅ docker run \
    -e HELM_VERSION="v2.14.1" \
    -e KUBECTL_VERSION="v1.14.3" \
    -e KUBE_MASTER=$KUBE_MASTER \
    -e KUBE_TOKEN=$KUBE_TOKEN \
    -e KUBE_CA=$KUBE_CA \
    pulsar256/helm-bin ls
```

### Standalone interactive

```bash
 ᐅ docker run \
    -e HELM_VERSION="v2.14.1" \
    -e KUBECTL_VERSION="v1.14.3" \
    -e KUBE_MASTER=$KUBE_MASTER \
    -e KUBE_TOKEN=$KUBE_TOKEN \
    -e KUBE_CA=$KUBE_CA \
    --entrypoint="bash" -it \
    pulsar256/helm-bin 

bash-4.4# helm ls
(...)
```

### Within drone.io
 
```yaml
kind: pipeline
name: default

steps:
- name: drone-integration-test
  image: pulsar256/helm-bin
  environment:
    HELM_VERSION: "v2.14.1"
    KUBECTL_VERSION: "v1.14.3"
    KUBE_CA: "Base64 CA.crt"
    KUBE_MASTER: "https://example.com:443"
    KUBE_TOKEN: "secrit service account token"
  commands:
    - helm version
    - helm ls
    - kubectl get pods
```

### Within drone.io + drone-kubernetes-secrets

When using a k8s service-account's token & ca.crt data via drone-kubernets-secrets plugin 

```
ᐅ kubectl get secrets
NAME                                      TYPE                                  DATA   AGE
(...)
drone-helm-user-secret                    kubernetes.io/service-account-token   3      2d7h
(...)
```

```yaml
kind: pipeline
name: default

steps:
- name: drone-integration-test
  image: pulsar256/helm-bin
  environment:
    HELM_VERSION: "v2.14.1"
    KUBECTL_VERSION: "v1.14.3"
    KUBE_MASTER: "https://example.com:443"
    KUBE_CA:
      from_secret: drone-helm-user-crt
    KUBE_TOKEN:
      from_secret: drone-helm-user-token
  commands:
    - helm ls

---
kind: secret
name: drone-helm-user-token
get:
  path: drone-helm-user-secret
  name: token
  
---
kind: secret
name: drone-helm-user-crt
get:
  path: drone-helm-user-secret
  name: ca.crt
```
