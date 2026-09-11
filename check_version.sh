#!/usr/bin/env bash
set -Eeu

readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# The image resolves the newest stable clojure when it is built and records it
# in /versions.json, so the expected version is read from the image rather
# than written down here. Writing it down here would pin the image to a
# release chosen when someone last edited this file.
readonly VERSIONS=$(docker run --rm -i ${IMAGE_NAME} sh -c 'cat /versions.json')
readonly VERSION_REGEX='"clojure":"([0-9.]+)"'
if [[ ! ${VERSIONS} =~ ${VERSION_REGEX} ]]; then
  echo "VERSION ERROR: /versions.json has no clojure property"
  echo "VERSION   FILE: ${VERSIONS}"
  exit 42
fi
readonly EXPECTED="${BASH_REMATCH[1]}"

# Asks the prefetched jar itself, so the gate fails if the number recorded at
# build time is not the clojure the image can actually start.
readonly PROJECT="(defproject v \"0\" :dependencies [[org.clojure/clojure \"${EXPECTED}\"]])"
readonly ACTUAL=$(docker run --rm -i ${IMAGE_NAME} sh -c "cd /tmp && echo '${PROJECT}' > project.clj && echo ':exit' | lein repl 2>/dev/null | grep '^Clojure' | awk '{print \$2}'")

if [ "${ACTUAL}" == "${EXPECTED}" ]; then
  echo "VERSION CONFIRMED as ${EXPECTED}"
else
  echo "VERSION EXPECTED: ${EXPECTED}"
  echo "VERSION   ACTUAL: ${ACTUAL}"
  exit 42
fi
