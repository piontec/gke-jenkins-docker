FROM ubuntu:14.04
MAINTAINER anonim@no.ne

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y apt-transport-https
# Add the repository to your APT sources
RUN echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list 
# Then import the repository key
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    ca-certificates \
    curl \
    lxc-docker \
    iptables \
    supervisor \
    default-jre

RUN echo 'DOCKER_OPTS="-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock"' > /etc/default/docker
EXPOSE 4243

#VOLUME /var/log/supervisor

# Install Jenkins Swarm agent
ENV HOME /home/jenkins-agent
RUN useradd -c "Jenkins agent" -d $HOME -m jenkins-agent
RUN usermod -aG docker jenkins-agent
RUN curl --create-dirs -sSLo \
    /usr/share/jenkins/swarm-client-jar-with-dependencies.jar \
    http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/1.22/swarm-client-1.22-jar-with-dependencies.jar \
    && chmod 755 /usr/share/jenkins

# Install gcloud
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN apt-get install -y -qq --no-install-recommends wget unzip python php5-mysql php5-cli php5-cgi openjdk-7-jre-headless openssh-client python-openssl \
  && cd /home/jenkins-agent \
  && wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip \
  && google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --disable-installation-options \
  && google-cloud-sdk/bin/gcloud --quiet components update pkg-go pkg-python pkg-java preview app \
  && google-cloud-sdk/bin/gcloud --quiet config set component_manager/disable_update_check true \
  && chown -R jenkins-agent /home/jenkins-agent/.config \
  && chown -R jenkins-agent google-cloud-sdk 
ENV PATH /home/jenkins-agent/google-cloud-sdk/bin:$PATH

# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run Docker and Swarm processe with supervisord 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY jenkins-docker-supervisor.sh /usr/local/bin/jenkins-docker-supervisor.sh
ENTRYPOINT ["/usr/local/bin/jenkins-docker-supervisor.sh"]

