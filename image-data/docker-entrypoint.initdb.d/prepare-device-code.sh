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

main() {
  repository_dir="${WORKING_DIRECTORY}"

  _readEnv

  if [ -d "$repository_dir" ] && [ -n "${ENVIRONMENT_ARRAY[*]}" ]; then

    for element in "${ENVIRONMENT_ARRAY[@]}"; do
    
      if [[ "$element" =~ "DEVICE_CODE" ]]; then

        device_code=$(echo "$element" | cut -d'=' -f2 | tr -d '"' | xargs)
        cd "$repository_dir" && source "build/envsetup.sh"
        breakfast "$device_code"
        
      fi
    done

  fi
}

main