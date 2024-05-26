#!/bin/bash

SHARED_SCRIPTS_DIRECTORY="/root/scripts"

if [ -d "${SHARED_SCRIPTS_DIRECTORY}" ]; then
  mapfile -t SCRIPTS < <(ls ${SHARED_SCRIPTS_DIRECTORY})

  for script in "${SCRIPTS[@]}"; do

    echo "[cleanup.sh]: Removing ${SHARED_SCRIPTS_DIRECTORY}/$script" >&2
    rm -f "${SHARED_SCRIPTS_DIRECTORY}/$script"

    if [ ! -f "${SHARED_SCRIPTS_DIRECTORY}/$script" ]; then

      echo "[cleanup.sh]: Succesfully removed ${SHARED_SCRIPTS_DIRECTORY}/$script" >&2

    fi

  done

fi