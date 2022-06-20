FROM homebrew/ubuntu22.04:latest

LABEL maintainer="Anthonius Munthi"

ENV SHELL /usr/bin/fish
ENV TERM xterm-256color
ENV PY_COLORS 1
ENV ANSIBLE_FORCE_COLOR 1
ENV HOMEBREW_NO_AUTO_UPDATE 0

RUN brew install \
      direnv \
      sops \
      ansible \
      age \
      go-task/tap/go-task \
      fish

# install oh-my-fish
RUN curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > /tmp/install \
  && NONINTERACTIVE=1 fish /tmp/install \
  && fish -c "omf install bobthefish" \
  && fish -c "omf theme bobthefish" \
  && rm /tmp/install

COPY ./requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml \
  && ansible-galaxy collection install -r /tmp/requirements.yml

RUN brew link python@3.10

COPY ./etc/config.fish /root/.config/fish/config.fish

COPY ./ /workstation
WORKDIR /workstation

ENV SOPS_AGE_KEY_FILE "/workstation/.private/secrets/age.txt"
ENV ANSIBLE_VAULT_PASSWORD_FILE "/workstation/.private/secrets/vault-password.txt"
RUN direnv allow . && ansible-playbook playbook-configure.yml

VOLUME ["/workstation"]

CMD ["fish"]
