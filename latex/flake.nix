{
  description = "Latex Document Builder";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      name = "main.pdf";
      src = ./.;
      minted = true;
      fonts = null;

      latexPackages = with pkgs; [
        (texlive.combine {
          inherit (texlive)
            scheme-medium
            environ
            biblatex
            biber
            pgfplots
            amsmath
            tkz-euclide
            gensymb
            upquote
            csquotes
            minted
            ;
        })
        which
        python39Packages.pygments
      ];
    in rec {
      packages.default = pkgs.stdenvNoCC.mkDerivation rec {
        inherit name src;
        buildInputs = latexPackages ++ pkgs.lib.optional minted [pkgs.which pkgs.python39Packages.pygments];
        
        TEXMFHOME = "./cache";
        TEXMFVAR = "./cache/var";
        OSFONTDIR = pkgs.lib.optionalString (fonts != null) "${fonts}/share/fonts";
        SOURCE_DATE_EPOCH = toString self.lastModified;

        buildPhase = ''
          runHook prebuild
          latexmk -interaction=nonstopmode -pdf -lualatex -pretex='\\pdfvariable suppressoptionalinfo 512\\relax' -usepretex -shell-escape
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          install -m644 -D *.pdf $out/${name}
          runHook postInstall
        '';

      };
    }
  );
}
