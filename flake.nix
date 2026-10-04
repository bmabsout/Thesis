{
  description = "My thesi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    typix.url = "github:loqusion/typix";
    typst-design.url = "github:bmabsout/typst-design";
    typst-design.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, typix, typst-design }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        typixLib = typix.lib.${system};
        
        fontPaths = [
          "./fonts"
          # "${pkgs.eb-garamond}/share/fonts/opentype"
          "${pkgs.libertinus}/share/fonts/opentype"
          "${pkgs.font-awesome_5}/share/fonts/truetype"
          "${pkgs.font-awesome_5}/share/fonts/opentype"
          "${pkgs.merriweather}/share/fonts"
          "${pkgs.crimson-pro}/share/fonts"
          "${pkgs.source-serif}/share/fonts"
          "${pkgs.jost}/share/fonts"
          "${pkgs.libre-baskerville}/share/fonts"
          "${pkgs.texlivePackages.baskervillef}/fonts"
          "${pkgs.lato}/share/fonts"
        ];
      in
      {
        devShells.default = typixLib.devShell {
          inherit fontPaths;
          packages = [
          ];
          # The design system, importable as "@local/typst-design:<version>".
          shellHook = ''
            export TYPST_PACKAGE_PATH=${typst-design.packages.${system}.default}
          '';
        };
      }
    );
}
