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

COPY version.txt /tmp
RUN lein --version | grep -f /tmp/version.txt
