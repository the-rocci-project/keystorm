#!/bin/bash

function configure_keystorm {
  # SECRET_KEY_BASE
  if [ -z ${SECRET_KEY_BASE+x} ] && [ -z ${SECRET_KEY_BASE_FILE+x} ]; then
    export SECRET_KEY_BASE=$(head -c 69 /dev/urandom | base64 -w 0)
  fi

  if [ ${SECRET_KEY_BASE_FILE+x} ]; then
    if [ ${SECRET_KEY_BASE+x} ]; then
      error_exit "Variables 'SECRET_KEY_BASE' and 'SECRET_KEY_BASE_FILE' cannot be set togather" 2
    fi

    export SECRET_KEY_BASE=$(cat ${SECRET_KEY_BASE_FILE})
  fi

  # KEYSTORM_TOKEN_CIPHER
  if [ -z ${KEYSTORM_TOKEN_CIPHER+x} ] && [ -z ${KEYSTORM_TOKEN_CIPHER_FILE+x} ]; then
    missing_var_exit "KEYSTORM_TOKEN_CIPHER_FILE"
  fi

  if [ ${KEYSTORM_TOKEN_CIPHER_FILE+x} ]; then
    if [ ${KEYSTORM_TOKEN_CIPHER+x} ]; then
      error_exit "Variables 'KEYSTORM_TOKEN_CIPHER' and 'KEYSTORM_TOKEN_CIPHER_FILE' cannot be set togather" 2
    fi

    export KEYSTORM_TOKEN_CIPHER=$(cat ${KEYSTORM_TOKEN_CIPHER_FILE})
  fi

  # KEYSTORM_TOKEN_KEY
  if [ -z ${KEYSTORM_TOKEN_KEY+x} ] && [ -z ${KEYSTORM_TOKEN_KEY_FILE+x} ]; then
    missing_var_exit "KEYSTORM_TOKEN_KEY_FILE"
  fi

  if [ ${KEYSTORM_TOKEN_KEY_FILE+x} ]; then
    if [ ${KEYSTORM_TOKEN_KEY+x} ]; then
      error_exit "Variables 'KEYSTORM_TOKEN_KEY' and 'KEYSTORM_TOKEN_KEY_FILE' cannot be set togather" 2
    fi

    export KEYSTORM_TOKEN_KEY=$(cat ${KEYSTORM_TOKEN_KEY_FILE})
  fi

  # KEYSTORM_TOKEN_IV
  if [ -z ${KEYSTORM_TOKEN_IV+x} ] && [ -z ${KEYSTORM_TOKEN_IV_FILE+x} ]; then
    missing_var_exit "KEYSTORM_TOKEN_IV_FILE"
  fi

  if [ ${KEYSTORM_TOKEN_IV_FILE+x} ]; then
    if [ ${KEYSTORM_TOKEN_IV+x} ]; then
      error_exit "Variables 'KEYSTORM_TOKEN_IV' and 'KEYSTORM_TOKEN_IV_FILE' cannot be set togather" 2
    fi

    export KEYSTORM_TOKEN_IV=$(cat ${KEYSTORM_TOKEN_IV_FILE})
  fi
}
