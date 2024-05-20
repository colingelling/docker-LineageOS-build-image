#!/bin/bash

SHARED_SCRIPTS_DIRECTORY="/root/scripts"

ENV_ARRAY=()
STATE=()

_readEnv() {

  mapfile -t env_file < <(find '/root/environment' -name '.env')
  
  if [ -n "${env_file[*]}" ]; then

    while IFS= read -r line || [[ -n $line ]]; do

      ENV_ARRAY+=("$line")

    done < <(cat "${env_file[0]}")

  fi

}

_isolateValue() {

    if [ -n "${ENV_ARRAY[*]}" ]; then

        for element in "${ENV_ARRAY[@]}"; do

            if [[ $element =~ "STATE" ]]; then

                read -ra STATE <<< "$element"

            fi

        done

    fi

}

_executeScripts() {

    mapfile -t DIRECTORY_CONTENT < <(ls ${SHARED_SCRIPTS_DIRECTORY})

    if [ -n "${DIRECTORY_CONTENT[*]}" ]; then

        for script in "${DIRECTORY_CONTENT[@]}"; do

            if [[ ! "${script,,}" =~ "main" ]] && [[ ! "${script,,}" =~ "cleanup" ]]; then

                source "${SHARED_SCRIPTS_DIRECTORY}/$script"

            fi

        done

    fi
}

main() {

    _readEnv
    _isolateValue

    for value in "${STATE[@]}"; do
        if [[ $value == 1 ]]; then
            echo && echo "[main.sh]: Your .env's STATE variable currently has reached the desired state which is $value. Building process starts now.."
            # TODO: Start scripts in order

            _executeScripts

            return 0
        elif [[ $value == 0 ]]; then
            echo && echo "[main.sh]: Your .env's STATE variable currently hasn't been set to 'on', change it to '1' to start the process of building."
            return 1
        fi
    done

}

# Loop to check whether the execution state has been changed or not
while ! main; do
    sleep 10
done