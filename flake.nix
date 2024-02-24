{
  outputs = { self, nixpkgs }: {
    lib.patchFont = { font, subfamily ? "", name, system }:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nerd-fonts = pkgs.stdenv.mkDerivation rec {
          name = "nerd-fonts";
          version = "3.1.1";
          src = pkgs.fetchurl {
            url =
              "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FontPatcher.zip";
            hash = "sha256-exG9u+ZF/4FxkiM/f6sdwCbOogGVncRhf1IX1SUN5PI=";
          };
          buildInputs = [ pkgs.fontforge pkgs.unzip ];

          sourceRoot = ".";

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -R font-patcher bin/ src/ $out/
            runHook postInstall
          '';
        };
        extract-subfamily = pkgs.stdenv.mkDerivation rec {
          name = "extract-subfamily";
          version = "1.0.0";

          buildInputs = [ (pkgs.python311.withPackages (p: [ p.fonttools ])) ];

          unpackPhase= ":";

          installPhase = "install -m755 -D ${./extract_subfamily.py} $out/bin/extract_subfamily";
        };
        packageName = name;
        extension = pkgs.lib.lists.last (pkgs.lib.strings.splitString "." font);

      in pkgs.stdenv.mkDerivation rec {
        name = packageName;
        version = "1.0";
        src = font;

        buildInputs = [ nerd-fonts pkgs.fontforge extract-subfamily ];

        unpackPhase = ''
          cp $src .
        '';

        buildPhase = ''
          [[ "${subfamily}" == "" ]] && cp ${src} partial.${extension}
          [[ "${subfamily}" != "" ]] && extract_subfamily ${src} partial.${extension} ${subfamily}
          fontforge -script ${nerd-fonts}/font-patcher partial.${extension} --name '${name}' --no-progressbars -c -out $out/
        '';

        installPhase = "";
      };

    devShell.aarch64-darwin = let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in pkgs.mkShell {
      buildInputs = [
        (pkgs.python311.withPackages (p: [ p.fonttools ]))
        pkgs.ruff
        pkgs.yapf
      ];
    };
  };
}
