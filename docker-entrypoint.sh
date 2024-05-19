#!/bin/bash

ENTRYPOINT_SCRIPTS_DIRECTORY="/docker-entrypoint.initdb.d"
SHARED_SCRIPTS_DIRECTORY="/root/scripts"
SHARED_ENVIRONMENT_DIRECTORY="/root/environment"

load_script() {
  FILE="${SHARED_SCRIPTS_DIRECTORY}/$script"

  if [ -f "${FILE}" ] && [[ "${FILE,,}" =~ "main" ]]; then
    source "${SHARED_SCRIPTS_DIRECTORY}/$script" && chmod +x "${SHARED_SCRIPTS_DIRECTORY}/$script"
    echo "[ENTRYPOINT]: Loaded ${SHARED_SCRIPTS_DIRECTORY}/$script" >&2
  fi
}

copy_environment() {

  mapfile -t ENV_FILE < <(find "/root/" -name ".env")

  if [ -n "${ENV_FILE[*]}" ]; then
  
    if [ -z "$(find "${SHARED_ENVIRONMENT_DIRECTORY}" -name ".env")" ]; then

      for file in "${ENV_FILE[@]}"; do

        echo "[ENTRYPOINT]: Copying $file to ${SHARED_ENVIRONMENT_DIRECTORY}" >&2
        cp "$file" "${SHARED_ENVIRONMENT_DIRECTORY}"

        if [ -f "${SHARED_ENVIRONMENT_DIRECTORY}/$file" ]; then
          echo "[ENTRYPOINT]: task succeeded." >&2
        fi

      done

    else
      echo "[ENTRYPOINT]: Environment file ${SHARED_ENVIRONMENT_DIRECTORY}/$file was found" >&2
    fi

  fi

}

main() {

  copy_environment

  if [ -d "${ENTRYPOINT_SCRIPTS_DIRECTORY}" ]; then

    mapfile -t DIRECTORY_CONTENT < <(ls ${ENTRYPOINT_SCRIPTS_DIRECTORY})

    for script in "${DIRECTORY_CONTENT[@]}"; do
      if [ ! -f "${SHARED_SCRIPTS_DIRECTORY}/$script" ]; then

        echo "[ENTRYPOINT]: Copying ${ENTRYPOINT_SCRIPTS_DIRECTORY}/$script to ${SHARED_SCRIPTS_DIRECTORY}" >&2
        cp "${ENTRYPOINT_SCRIPTS_DIRECTORY}/$script" "${SHARED_SCRIPTS_DIRECTORY}"

        if [ -f "${SHARED_SCRIPTS_DIRECTORY}/$script" ]; then
          echo "[ENTRYPOINT]: task succeeded." >&2
        fi

        load_script

      else
        echo "[ENTRYPOINT]: Executable ${SHARED_SCRIPTS_DIRECTORY}/$script was found" >&2
        load_script
      fi
    done

  fi
}

main