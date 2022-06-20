#!/bin/bash

#set -u

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
# shellcheck disable=SC2292
if [ -z "${BASH_VERSION:-}" ]
then
  abort "Bash is required to interpret this script."
fi

#  [[ "$(python3 -V)" =~ "Python 3" ]] && echo "Python 3 is installed"
PYTHON=$(command -v python)
if [ -z "${PYTHON:-}" ]
then
  abort "Python is required to execute this script."
fi

PIP=$(command -v pip)
if [ -z "${PIP:-}" ]
then
  abort "Python pip is required to execute this script."
fi

PIP_VERSION="$(eval $PIP --version)"
PYTHON_VERSION="$(eval $PYTHON --version)"
export PY_COLORS=1
export ANSIBLE_FORCE_COLOR=1

install_ansible() {
  echo "Using pip: ${PIP_VERSION}"
  echo "Using python: ${PYTHON_VERSION}"
  $PIP install --upgrade pip
  $PIP install wheel setuptools
}


install_ansible
