FROM ruby:2.4-stretch

ARG branch=master
ARG version

ENV name="keystorm" \
    project="the-rocci-project" \
    installDir="/opt"
ENV appDir="${installDir}/${name}-${version}" \
    logDir="/var/log/${name}" \
    TERM="xterm"

LABEL application=${name} \
      description="Federated authentication component for rOCCI-server" \
      maintainer="kimle@cesnet.cz" \
      version=${version} \
      branch=${branch}

SHELL ["/bin/bash", "-c"]

RUN curl -SsL https://github.com/${project}/${name}/archive/v${version}.tar.gz | tar -xzC ${installDir}

RUN useradd --system --shell /bin/false --home ${appDir} ${name} && \
    usermod -L ${name} && \
    mkdir -p ${appDir}/log && \
    ln -s ${appDir}/log ${logDir} && \
    chown -R ${name}:${name} ${appDir} ${appDir}/log ${logDir}

COPY bin/* /keystorm/bin/

USER ${name}

VOLUME ["${logDir}"]

WORKDIR ${appDir}

RUN bundle install --path ./vendor --deployment --without development test

EXPOSE 3000

ENTRYPOINT ["/keystorm/bin/keystorm-wrapper.sh"]
