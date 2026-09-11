#!/bin/sh -e

# Prefetches the clojure compiler, at the newest stable release, and records
# which release that was so the images built on this one ask for the same one.

# Maven Central's own <release> element is whatever was published most
# recently, and that includes pre-releases: it is 1.13.0-alpha6 at the time of
# writing. So the version list is filtered to the three-number releases and
# the highest of those is taken. A kata runs with no network, so the jar
# prefetched here is the only clojure a kata can have, and it should not be a
# pre-release.
apt-get update
apt-get install --yes --no-install-recommends curl

CLOJURE_VERSION=$(curl --silent --fail \
  https://repo1.maven.org/maven2/org/clojure/clojure/maven-metadata.xml \
  | grep -oE '<version>[0-9]+\.[0-9]+\.[0-9]+</version>' \
  | sed -e 's|</*version>||g' \
  | sort --version-sort \
  | tail -1)

apt-get remove --yes curl

if [ -z "${CLOJURE_VERSION}" ]; then
  echo 'ERROR: could not resolve the newest stable clojure release' >&2
  exit 1
fi

# Read by check_version.sh and by the images built on this one, so that all of
# them state the version this image actually holds rather than repeating a
# number written down somewhere else.
echo "{\"clojure\":\"${CLOJURE_VERSION}\"}" > /versions.json

cd /tmp
cat > project.clj <<EOF
(defproject prefetch-clojure "0"
  :description "Project to prefetch the clojure compiler"
  :dependencies [[org.clojure/clojure "${CLOJURE_VERSION}"]])
EOF

lein deps
rm project.clj
mv ~/.lein ~/.m2 /
ln -sf /.lein ~
ln -sf /.m2 ~
chown -R sandbox:sandbox /.lein /.m2
