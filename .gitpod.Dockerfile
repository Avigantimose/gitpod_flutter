FROM gitpod/workspace-full-vnc

ENV FLUTTER_HOME=/home/gitpod/flutter
ENV PATH=/usr/lib/dart/bin:$FLUTTER_HOME/bin:$PATH

USER root

RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get -y install build-essential dart gcc make && \
    apt-get clean && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*;

USER gitpod

RUN cd /home/gitpod && wget -qO flutter_sdk.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.9.1+hotfix.6-stable.tar.xz \
    && tar -xvf flutter_sdk.tar.xz && rm flutter_sdk.tar.xz;

USER root