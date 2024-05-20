#!/bin/bash

WORKING_DIRECTORY="/root/android/lineage"
ENV_ARRAY=()

_readEnv() {

  mapfile -t env_file < <(find '/root/environment' -name '.env')
  
  if [ -n "${env_file[*]}" ]; then

    while IFS= read -r line; do

      ENV_ARRAY+=("$line")

    done < <(cat "${env_file[0]}")

  fi

}

initializeRepository() {
  if [ -d "${WORKING_DIRECTORY}" ]; then

    echo "" && echo "[initialize-lineage-repository.sh]: Initializing LineageOS repository.." >&2
    cd "${WORKING_DIRECTORY}" && repo init -u https://github.com/LineageOS/android.git -b "$branch" --git-lfs >&2
    repo sync >&2

  fi
}

main() {
  _readEnv

  if [ -n "${ENV_ARRAY[*]}" ]; then

    for element in "${ENV_ARRAY[@]}"; do
      if [[ "BRANCH" =~ $element ]]; then
        branch="$element"
        initializeRepository
      fi
    done

  fi
}

main
