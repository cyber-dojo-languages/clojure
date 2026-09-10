#!/usr/bin/env bash
set -Eeu

readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
# The probe asks for the version the image prefetches, not for "RELEASE".
# "RELEASE" is whatever was published most recently, so it reports on upstream's
# latest release rather than on this image, and a pre-release upstream turns this
# gate red without anything here having changed.
readonly EXPECTED=1.12
readonly ACTUAL=$(docker run --rm -i ${IMAGE_NAME} sh -c 'cd /tmp && echo "(defproject v \"0\" :dependencies [[org.clojure/clojure \"1.12.4\"]])" > project.clj && echo ":exit" | lein repl 2>/dev/null | grep "^Clojure" | awk "{print \$2}"')

if echo "${ACTUAL}" | grep -q "${EXPECTED}"; then
  echo "VERSION CONFIRMED as ${EXPECTED}"
else
  echo "VERSION EXPECTED: ${EXPECTED}"
  echo "VERSION   ACTUAL: ${ACTUAL}"
  exit 42
fi
