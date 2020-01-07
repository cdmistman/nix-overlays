{ callPackage, fetchzip, fetchFromGitHub, stdenv, pkgconfig, openssl }:

oself: osuper:

with oself;

let
  faradayPackages = callPackage ./faraday.nix {
    ocamlPackages = oself;
  };
  httpafPackages = callPackage ./httpaf.nix {
    ocamlPackages = oself;
  };

  h2Packages = callPackage ./h2.nix {
    ocamlPackages = oself;
  };

  opamPackages = callPackage ./opam.nix {
    ocamlPackages = oself;
  };

  lambda-runtime-packages = callPackage ./lambda-runtime.nix {
    ocamlPackages = oself;
  };

in
  opamPackages //
  faradayPackages //
  httpafPackages //
  h2Packages //
  lambda-runtime-packages // {
    ssl = osuper.ssl.overrideAttrs (o: {
      version = "0.5.9-dev";
      src = fetchFromGitHub {
        owner = "savonet";
        repo = "ocaml-ssl";
        rev = "fbffa9b";
        sha256 = "1pp9hig7kkzhr3n1rkc177mnahrijx6sbq59xjr8bnbfsmn1l2ay";
      };

      nativeBuildInputs = [ dune pkgconfig ];
      propagatedBuildInputs = [ openssl.dev ];
    });

    piaf = callPackage ./piaf.nix { ocamlPackages = oself; };

    lwt4 = osuper.lwt4.overrideAttrs (o: rec {
      version = "5.1.1";

      src = fetchzip {
        url = "https://github.com/ocsigen/${o.pname}/archive/${version}.tar.gz";
        sha256 = "1nl7rdnwfdhwcsm5zpay1nr9y5cbapd9x1qzily7zk9ab4v52m8g";
      };
    });

    camlzip = osuper.camlzip.overrideAttrs (o: {
      buildFlags = if stdenv.hostPlatform != stdenv.buildPlatform then
        "all zip.cmxa"
        else
          o.buildFlags;

      src = builtins.fetchurl {
        url = "https://github.com/xavierleroy/camlzip/archive/rel110.tar.gz";
        sha256 = "1ckxf9d19x63crkcn54agn5p77a9s84254s84ig53plh6rriqijz";
      };
    });

    ezgzip = buildDunePackage {
      pname = "ezgzip";
      version = "0.2.3-dev";
      src = fetchFromGitHub {
        owner = "hcarty";
        repo = "ezgzip";
        rev = "v0.2.3";
        sha256 = "0x2i40n289k4gn2hn2hrmh6z9j570nbim368iddy54aqb97hj3ir";
      };
      propagatedBuildInputs = [rresult astring ocplib-endian camlzip result ];
    };

    dose3 = callPackage ./dose3 { ocamlPackages = oself; };

    cudf = callPackage ./cudf.nix { ocamlPackages = oself; };
  }
