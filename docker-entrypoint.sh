#!/bin/bash

ENTRYPOINT_SCRIPTS_DIRECTORY="/docker-entrypoint.initdb.d"
SHARED_SCRIPTS_DIRECTORY="/root/scripts"
SHARED_ENVIRONMENT_DIRECTORY="/root/environment"

copy_environment() {

  mapfile -t ENV_FILE < <(find "/root/" -name ".env")

  echo

  if [ -n "${ENV_FILE[*]}" ]; then
  
    if [ -z "$(find "${SHARED_ENVIRONMENT_DIRECTORY}" -name ".env")" ]; then

      for file in "${ENV_FILE[@]}"; do

        echo "[ENTRYPOINT]: Copying $file to ${SHARED_ENVIRONMENT_DIRECTORY}" >&2
        cp "$file" "${SHARED_ENVIRONMENT_DIRECTORY}"

        if [ -f "${SHARED_ENVIRONMENT_DIRECTORY}/$file" ]; then
          echo "[ENTRYPOINT]: Task succeeded." >&2
        fi

      done

    else
      echo "[ENTRYPOINT]: Environment file was found in ${SHARED_ENVIRONMENT_DIRECTORY}" >&2
    fi

  fi

}

copy_scripts() {
  if [ -d "${ENTRYPOINT_SCRIPTS_DIRECTORY}" ]; then

    mapfile -t DIRECTORY_CONTENT < <(ls ${ENTRYPOINT_SCRIPTS_DIRECTORY})

    for script in "${DIRECTORY_CONTENT[@]}"; do
      if [ ! -f "${SHARED_SCRIPTS_DIRECTORY}/$script" ]; then

        echo "[ENTRYPOINT]: Copying ${ENTRYPOINT_SCRIPTS_DIRECTORY}/$script to ${SHARED_SCRIPTS_DIRECTORY}" >&2
        cp "${ENTRYPOINT_SCRIPTS_DIRECTORY}/$script" "${SHARED_SCRIPTS_DIRECTORY}"

        if [ -f "${SHARED_SCRIPTS_DIRECTORY}/$script" ]; then
          echo "[ENTRYPOINT]: Task succeeded." >&2
        fi

      else
        echo "[ENTRYPOINT]: Executable file '$script' was found in ${SHARED_SCRIPTS_DIRECTORY}" >&2
      fi
    done

  fi
}

execute_main() {
  for script in "${DIRECTORY_CONTENT[@]}"; do
    FILE="${SHARED_SCRIPTS_DIRECTORY}/$script"

    if [ -f "${FILE}" ] && [[ "${FILE,,}" =~ "main" ]]; then
      source "${SHARED_SCRIPTS_DIRECTORY}/$script"
      echo "[ENTRYPOINT]: Loaded ${SHARED_SCRIPTS_DIRECTORY}/$script" >&2
    fi
  done
}

loader() {

  copy_environment
  copy_scripts

  execute_main

}

loader