{stdenv, fetchurl, ocaml, findlib, lambdaTerm, ocaml_lwt, makeWrapper,
 ocaml_react, camomile, zed, cppo, camlp4, ppx_tools
}:

stdenv.mkDerivation rec {
  version = "1.19.2";
  name = "utop-${version}";

  src = fetchurl {
    url = "https://github.com/diml/utop/archive/${version}.tar.gz";
    sha256 = "0hxybkqmrh0sz1yyyrgzdmxp46gda4vk22pv07s0qpfg2dpv56jh";
  };

  buildInputs = [ ocaml findlib makeWrapper cppo camlp4 ppx_tools ];

  propagatedBuildInputs = [ lambdaTerm ocaml_lwt ];

  createFindlibDestdir = true;

  configureFlags = [ "--enable-camlp4" ]
  ++ stdenv.lib.optional (ppx_tools != null) "--enable-interact";

  buildPhase = ''
    make
    make doc
    '';

  postFixup =
  let ocamlVersion = (builtins.parseDrvName (ocaml.name)).version;
  in
   ''
   for prog in "$out"/bin/*
   do
    wrapProgram $prog --set CAML_LD_LIBRARY_PATH "${ocaml_lwt}"/lib/ocaml/${ocamlVersion}/site-lib/lwt/:"${lambdaTerm}"/lib/ocaml/${ocamlVersion}/site-lib/lambda-term/:'$CAML_LD_LIBRARY_PATH' --set OCAMLPATH "${ocaml_lwt}"/lib/ocaml/${ocamlVersion}/site-lib:${ocaml_react}/lib/ocaml/${ocamlVersion}/site-lib:${camomile}/lib/ocaml/${ocamlVersion}/site-lib:${zed}/lib/ocaml/${ocamlVersion}/site-lib:${lambdaTerm}/lib/ocaml/${ocamlVersion}/site-lib:"$out"/lib/ocaml/${ocamlVersion}/site-lib:'$OCAMLPATH'
   done
   '';

  meta = {
    description = "Universal toplevel for OCaml";
    longDescription = ''
    utop is an improved toplevel for OCaml. It can run in a terminal or in Emacs. It supports line edition, history, real-time and context sensitive completion, colors, and more.

    It integrates with the tuareg mode in Emacs.
    '';
    homepage = https://github.com/diml/utop;
    license = stdenv.lib.licenses.bsd3;
    platforms = ocaml.meta.platforms or [];
    maintainers = [
      stdenv.lib.maintainers.gal_bolle
    ];
  };
}
