FROM ubuntu:20.04
LABEL maintainer="Anthonius Munthi"

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      apt-utils \
      build-essential \
      locales \
      libffi-dev \
      libssl-dev \
      libyaml-dev \
      python3-dev \
      python3-setuptools \
      python3-pip \
      python3-yaml \
      software-properties-common \
      rsyslog systemd systemd-cron sudo iproute2 \
      git \
      curl \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Install Ansible
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    fish \
    curl \
  && rm -rf /var/lib/apt/lists/* \
  && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
  && apt-get clean

RUN curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > /tmp/install \
  && NONINTERACTIVE=1 fish /tmp/install \
  && chsh -s /usr/bin/fish \
  && git clone --depth=1 https://github.com/oh-my-fish/theme-bobthefish /root/.local/share/omf/themes/bobthefish \
  && rm /tmp/install

ENV SHELL /usr/bin/fish

# Install Ansible via Pip.
RUN pip install --upgrade pip \
  && pip install setuptools wheel \
  && pip install ansible

COPY ./bin/initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file
RUN mkdir -p /etc/ansible \
  && echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

COPY ./ /workstation
WORKDIR /workstation
RUN rm -rf /workstation/.git \
  rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["fish"]
