#!/bin/sh -e

cd /tmp
lein deps
rm project.clj
mv ~/.lein ~/.m2 /
ln -sf /.lein ~
ln -sf /.m2 ~
chown -R sandbox:sandbox /.lein /.m2
