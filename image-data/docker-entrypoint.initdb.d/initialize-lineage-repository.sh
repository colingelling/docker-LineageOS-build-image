#!/bin/bash

WORKING_DIRECTORY="/root/android/lineage"
ENVIRONMENT_ARRAY=()

_readEnv() {

  # Find the environment file, collect all values to store them in an array

  mapfile -t env_file < <(find '/root/environment' -name '.env')
  
  if [ -n "${env_file[*]}" ]; then

    while IFS="=" read -r line; do

      if [ -n "$line" ]; then

        ENVIRONMENT_ARRAY+=("$line")

      fi

    done < <(cat "${env_file[0]}")

  fi

}

initializeRepository() {
  if [ -d "${WORKING_DIRECTORY}" ]; then

    echo && echo "[initialize-lineage-repository.sh]: Initializing LineageOS repository within ${WORKING_DIRECTORY}, this may take a while.." >&2
    echo && cd "${WORKING_DIRECTORY}" && repo init -u https://github.com/LineageOS/android.git -b "$branch" --git-lfs
    repo sync

    echo && echo "[initialize-lineage-repository.sh]: Synced LineageOS repository succeeded." >&2

  fi
}

main() {
  _readEnv

  if [ -n "${ENVIRONMENT_ARRAY[*]}" ]; then

    for element in "${ENVIRONMENT_ARRAY[@]}"; do
      if [[ "$element" =~ "BRANCH" ]]; then

        branch=$(echo "$element" | cut -d'=' -f2 | tr -d '"' | xargs)
        initializeRepository
        
      fi
    done


  fi
}

main
