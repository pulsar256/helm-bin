FROM alpine:3.9

# used to precache this helm & kubectl versions and bake them into the image.
ARG helm_version="v2.14.1"
ARG kubectl_version="v1.14.3"

LABEL maintainer="Paul Rogalinski-Pinter <paul@paul.vc>" \
description="helm and kubectl binaries with drone.io integration" \
base="alpine" \
helm_version="${helm_version}" \
kubectl_version="${kubectl_version}"

LABEL org.label-schema.schema-version="1.0" \
org.label-schema.name="pulsar256/helm-bin" \
org.label-schema.description="helm and kubectl binaries with drone.io integration" \
org.label-schema.url="https://github.com/pulsar256/helm-bin" \
org.label-schema.vcs-url="https://github.com/pulsar256/helm-bin" \
org.label-schema.docker.cmd="docker run \
-e HELM_VERSION=v2.14.1 \
-e KUBECTL_VERSION=v1.14.3 \
-e KUBE_MASTER=$KUBE_MASTER \
-e KUBE_TOKEN=$KUBE_TOKEN \
-e KUBE_CA=$KUBE_CA \
pulsar256/helm-bin ls"

COPY *.sh /

RUN apk add --no-cache curl ca-certificates bash upx
RUN sh /precache.sh $helm_version $kubectl_version \
&&  ln -s /init.sh /bin/kubectl \
&&  ln -s /init.sh /bin/helm  \
&&  rm /tmp/*

ENTRYPOINT [ "/init.sh" ]
