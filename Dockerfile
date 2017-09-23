FROM ubuntu:16.04 as ctbuilder

RUN apt-get update && \
    apt-get install -y gcc gperf bison flex texinfo help2man make libncurses5-dev python-dev wget xz-utils bzip2 patch gawk build-essential
ARG CTUSER=ctbuilder
RUN mkdir /home/${CTUSER} && \
    groupadd -r ${CTUSER} -g 1000 && \
    useradd -u 1000 -r -g ${CTUSER} -d /home/${CTUSER} -s /bin/bash -c "Docker image user" ${CTUSER} && \
    chown -R ${CTUSER}:${CTUSER} /home/${CTUSER}

USER ${CTUSER}:${CTUSER}
WORKDIR /home/${CTUSER}
ARG VERSION=1.23.0
ARG PACKAGE=crosstool-ng
ARG CT_VERSION=${PACKAGE}-${VERSION}

RUN wget http://crosstool-ng.org/download/${PACKAGE}/${CT_VERSION}.tar.xz && \
    xzcat ${CT_VERSION}.tar.xz | tar xvf -
WORKDIR /home/${CTUSER}/${CT_VERSION}
RUN ./configure --prefix=/home/${CTUSER}/${PACKAGE}

RUN make && make install 
COPY crosstool-ng.config /home/${CTUSER}/${CT_VERSION}/.config
RUN export PATH="${PATH}:/home/${CTUSER}/${PACKAGE}/bin" && \
    ct-ng build

WORKDIR /home/${CTUSER}

RUN chmod u+w x-tools/x86_64-unknown-linux-gnu && \
    chmod u+w x-tools/x86_64-unknown-linux-gnu/build.log.bz2 && ls -la x-tools && \
    rm -f x-tools/x86_64-unknown-linux-gnu/build.log.bz2 && \
    chmod u-w x-tools/x86_64-unknown-linux-gnu && \
    tar cvf x86_64-unknown-linux-gnu.tar -C x-tools . && \
    xz x86_64-unknown-linux-gnu.tar

FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y xz-utils bzip2 && \
    rm -rf /var/lib/apt/lists/*

ARG CTUSER=ctbuilder
COPY --from=ctbuilder /home/${CTUSER}/x86_64-unknown-linux-gnu.tar.xz /opt/crosstool-ng/
WORKDIR /opt/crosstool-ng

RUN xzcat x86_64-unknown-linux-gnu.tar.xz | tar xf - && \
    rm x86_64-unknown-linux-gnu.tar.xz
