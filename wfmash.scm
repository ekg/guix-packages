(define-module (wfmash)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages jemalloc)
  #:use-module (gnu packages bioinformatics)
  #:use-module (gnu packages maths))

(define-public wfmash
  (let ((version "0.7.0")
        (commit "26ca3113ba9e6ef4ce50644ab51ea6d9f0255e04")
        (package-revision "4"))
    (package
     (name "wfmash")
     (version (string-append version "+" (string-take commit 7) "-" package-revision))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ekg/wfmash.git")
                    (commit commit)
                    (recursive? #f)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "09l97yfr6nlznz34qni8rln8zh8zhn58049fz0naichpxzsfpb1n"))))
     (build-system cmake-build-system)
     (arguments
      `(#:phases
        (modify-phases
         %standard-phases
         ;; This stashes our build version in the executable
         (add-after 'unpack 'set-version
           (lambda _
             (mkdir "include")
             (with-output-to-file "include/wfmash_git_version.hpp"
               (lambda ()
                 (format #t "#define WFMASH_GIT_VERSION \"~a\"~%" version)))
             #t))
         (delete 'check))
        #:make-flags (list (string-append "CC=" ,(cc-for-target))
                           (string-append "CXX=" ,(cxx-for-target)))))
     (inputs
      `(("gcc" ,gcc-11)
        ("gsl" ,gsl)
        ("jemalloc" ,jemalloc)
        ("htslib" ,htslib)
        ("zlib" ,zlib)))
     (synopsis "base-accurate DNA sequence alignments using WFA and mashmap2")
     (description "wfmash is a fork of MashMap that implements
base-level alignment using the wavefront alignment algorithm WFA. It
completes an alignment module in MashMap and extends it to enable
multithreaded operation. A single command-line interface simplfies
usage. The PAF output format is harmonized and made equivalent to that
in minimap2, and has been validated as input to seqwish.")
     (home-page "https://github.com/ekg/wfmash")
     (license license:expat))))
