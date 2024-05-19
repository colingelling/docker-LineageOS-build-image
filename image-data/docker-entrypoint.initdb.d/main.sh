#!/bin/bash

ENV_ARRAY=()

_readEnv() {

  mapfile -t env_file < <(find '/root/environment' -name '.env')
  
  if [ -n "${env_file[*]}" ]; then

    echo "${env_file[0]}"

    while IFS= read -r line; do

      ENV_ARRAY+=("$line")

    done < <(cat "${env_file[0]}")

  fi

}

checkState() {
    if [ "${STATE}" == 1 ]; then
        echo "The variable has reached the desired state which is 1."
        return 0
    else
        echo "The variable is not in the desired state. Current state: ${STATE}"
        return 1
    fi
}

main() {

    _readEnv

    if [ -n "${ENV_ARRAY[*]}" ]; then

        for element in "${ENV_ARRAY[@]}"; do

            if [[ "STATE" =~ $element ]]; then

                STATE=$element
                checkState

            fi

        done

    fi

}

# Loop to check whether the execution state has been changed or not
while ! main; do
    sleep 10
done