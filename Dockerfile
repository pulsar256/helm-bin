FROM alpine:3.9

ARG helm_version="v2.14.1"
ARG kubectl_version="v1.14.3"

LABEL maintainer="Paul Rogalinski-Pinter <paul@paul.vc>"
LABEL description="helm"
LABEL base="alpine"
LABEL helm_version="${helm_version}"
LABEL kubectl_version="${kubectl_version}"

RUN apk add --no-cache curl ca-certificates bash

RUN mkdir -p $HOME/tmp/
COPY *.sh /

RUN sh /precache.sh $helm_version $kubectl_version
RUN ln -s /init.sh /bin/kubectl
RUN ln -s /init.sh /bin/helm

ENTRYPOINT [ "/init.sh" ]
