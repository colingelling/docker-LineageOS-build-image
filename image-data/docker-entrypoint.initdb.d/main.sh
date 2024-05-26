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

execute() {

    mapfile -t DIRECTORY_CONTENT < <(ls ${SHARED_SCRIPTS_DIRECTORY})

    if [ -n "${DIRECTORY_CONTENT[*]}" ]; then

        for script in "${DIRECTORY_CONTENT[@]}"; do

            if [[ ! "${script,,}" =~ "main" ]] && [[ ! "${script,,}" =~ "cleanup" ]]; then

                source "${SHARED_SCRIPTS_DIRECTORY}/$script"

            fi

        done

    fi
}

check_state() {
    local state
    for state in "${STATE[@]}"; do
        if [[ $state == 1 ]]; then

            echo && echo "[main.sh]: You started the build process in order to get LineageOS ready. This process is starting now.." && echo
            execute

            return 0

        elif [[ $state == 0 ]]; then

            if [[ $message_displayed == false ]]; then
                echo && echo "[main.sh]: Your .env's STATE variable currently hasn't been set to 'on', change it to '1' to start the build process to get LineageOS ready." && echo
                message_displayed=true
            fi

            return 1

        fi
    done
}

main() {

    _readEnv
    _isolateValue

    check_state

}

message_displayed=false

# Iterate to check whether the execution state has been changed or not
while ! main; do
    sleep 10
done