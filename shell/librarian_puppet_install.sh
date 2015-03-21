#!/bin/sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Library
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Installs puppet-librarian
InstallLibrarianPuppet () {
  # ensure librarian-puppet is not already installed
  $(which librarian-puppet > /dev/null 2>&1)

  if [ "$?" -eq '0' ]; then
    return
  fi

  # try to install librarian-puppet
  echo 'Attempting to install librarian-puppet'

  gem install librarian-puppet --version "$version"

  if [ "$?" -ne '0' ]; then
    echo 'Failed to install librarian-puppet'
    exit $?
  fi
}

# Installs ruby-dev
InstallRubyDev () {
  # ensure it is not already installed
  $(dpkg -s ruby-dev > /dev/null 2>&1)

  if [ "$?" -eq '0' ]; then
    return
  fi

  # try to install it with the appropriate package manager
  echo 'Attempting to install Ruby devkit...'

  if [ "${FOUND_YUM}" -eq '0' ]; then
    yum -q -y makecache
    yum -q -y install ruby-dev
  elif [ "${FOUND_APT}" -eq '0' ]; then
    apt-get -q -y install ruby-dev
  fi

  if [ "$?" -ne '0' ]; then
    echo 'Failed to install Ruby devkit...'
    exit $?
  fi
}

#Installs git
InstallGit () {
  # ensure git is not already installed
  $(which git > /dev/null 2>&1)

  if [ "$?" -eq '0' ]; then
    return
  fi

  # try to install git with the appropriate package manager
  echo 'Attempting to install Git...'

  if [ "${FOUND_YUM}" -eq '0' ]; then
    yum -q -y makecache
    yum -q -y install git
  elif [ "${FOUND_APT}" -eq '0' ]; then
    apt-get -q -y install git
  fi

  if [ "$?" -ne '0' ]; then
    echo 'Failed to install Git...'
    exit $?
  fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Ensure we have one supported package manager, up to date
$(which apt-get > /dev/null 2>&1)
FOUND_APT=$?

$(which yum > /dev/null 2>&1)
FOUND_YUM=$?

if [ "${FOUND_YUM}" -ne '0' -a "${FOUND_APT}" -ne '0' ]; then
  echo 'No supported package installer available. You may need to install git and librarian-puppet manually.'
  exit 1
fi

if [ "${FOUND_APT}" -eq '0' ]; then
  apt-get -q -y update
fi

# Collect the parameters
while getopts :v: opt; do
  case "$opt" in
    v) version="$OPTARG"
    ;;
    \?) echo "Unknown option -$OPTARG. Usage: $0 -v version" >&2
    ;;
  esac
done

# Install the appropriate packages
InstallGit
InstallRubyDev
InstallLibrarianPuppet
