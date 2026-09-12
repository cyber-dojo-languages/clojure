#!/usr/bin/env bash
set -Eeu

readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# Written down here so the gate fails when the floating base image moves to a
# different clojure. Reading it from the image instead would compare the image
# against itself and pass whatever the move brought in.
readonly EXPECTED=1.12

# Reads the clojure the image resolved and prefetched when it was built, so the
# gate fails when that is not the one named above. Matching on the leading
# major.minor lets a patch release through and stops only a minor or major move.
readonly VERSIONS=$(docker run --rm -i ${IMAGE_NAME} sh -c 'cat /versions.json')
readonly VERSION_REGEX='"clojure":"([0-9.]+)"'
if [[ ! ${VERSIONS} =~ ${VERSION_REGEX} ]]; then
  echo "VERSION ERROR: /versions.json has no clojure property"
  echo "VERSION   FILE: ${VERSIONS}"
  exit 42
fi
readonly ACTUAL="${BASH_REMATCH[1]}"

if echo "${ACTUAL}" | grep -q "${EXPECTED}"; then
  echo "VERSION CONFIRMED as ${EXPECTED}"
else
  echo "VERSION EXPECTED: ${EXPECTED}"
  echo "VERSION   ACTUAL: ${ACTUAL}"
  exit 42
fi
