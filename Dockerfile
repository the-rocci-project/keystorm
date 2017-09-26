FROM ruby:2.4-stretch

ARG branch=master
ARG version

ENV name="keystorm"
ENV appDir="/opt/${name}" \
    logDir="/var/log/${name}" \
    TERM="xterm"

LABEL application=${name} \
      description="Federated authentication component for rOCCI-server" \
      maintainer="kimle@cesnet.cz" \
      version=${version} \
      branch=${branch}

SHELL ["/bin/bash", "-c"]

RUN git clone https://github.com/the-rocci-project/keystorm.git ${appDir}

RUN useradd --system --shell /bin/false --home ${appDir} ${name} && \
    usermod -L ${name} && \
    mkdir -p ${appDir}/log && \
    ln -s ${appDir}/log ${logDir} && \
    chown -R ${name}:${name} ${appDir} ${appDir}/log ${logDir}

USER ${name}

VOLUME ["${logDir}"]

WORKDIR ${appDir}

RUN bundle install --path ./vendor --deployment --without development test

EXPOSE 3000

ENTRYPOINT ["bundle", "exec", "--keep-file-descriptors", "puma"]
