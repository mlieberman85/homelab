#!/run/current-system/sw/bin/bash

# TODO: This should probably be in python or something

# NOTE: Script expects to be run with sudo or with tctl permissions.
IGNORED_USERS=("mlieberman")

TELEPORT_USERS=$(tctl users ls | tail -n +3 | awk '{ print $1 }')

for ignored in ${IGNORED_USERS[@]}
do
  TELEPORT_USERS="${TELEPORT_USERS[@]/$ignored}"
done
TELEPORT_USERS="${TELEPORT_USERS#"${TELEPORT_USERS%%[![:space:]]*}"}"
readarray ARR <<<$TELEPORT_USERS
ARR=(${ARR[*]})
echo "["
STR=$(printf "  \"%s\",\n" "${ARR[@]}")
echo "${STR%,}"
echo "]"
