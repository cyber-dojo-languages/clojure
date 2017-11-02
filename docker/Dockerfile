FROM  clojure:lein-2.7.1-alpine
LABEL maintainer=frederic.merizen@soft-xki.com

ENV LEIN_ROOT=1

COPY project.clj /tmp
RUN cd /tmp \
 && lein deps \
 && rm project.clj \
 && mv ~/.lein ~/.m2 / \
 && ln -sf /.lein ~ \
 && ln -sf /.m2 ~ \
 && chown -R nobody /.lein /.m2

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install tini (for pid 1 zombie reaping)
RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini
ENTRYPOINT [ "/sbin/tini", "--" ]
