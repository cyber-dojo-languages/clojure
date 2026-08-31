; The version is named rather than asked for as "RELEASE", because "RELEASE" is
; whatever was published most recently, including a pre-release. It resolves at
; the time of writing to 1.13.0-alpha6, so a rebuild would prefetch that and
; leave the version the start-points ask for absent from the image. A kata runs
; with no network, so a dependency the image did not prefetch cannot be had.
(defproject prefetch-clojure "0"
  :description "Project to prefetch the clojure compiler"
  :dependencies [[org.clojure/clojure "1.12.4"]])
