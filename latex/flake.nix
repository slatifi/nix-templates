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

      fontsConf = pkgs.makeFontsConf {
        fontDirectories = [ 
          pkgs.fira-code 
          pkgs.noto-fonts 
        ];
      };

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

      devShells.default = pkgs.mkShell {
        buildInputs = latexPackages ++ [pkgs.fontconfig pkgs.fira-code];
        
        shellHook = ''
          export FONTCONFIG="${fontsConf}"
          echo "════════════════════════════════════════"
          echo "  📄 LaTeX Development Environment"
          echo "════════════════════════════════════════"
          echo ""
          echo "  texb      - Build your document"
          echo "  texclean  - Remove auxiliary files"
          echo ""
          
          alias texclean='rm -f *.aux *.bbl *.bcf *.blg *.idx *.ind *.ist *.lof *.lot *.out *.toc *.acn *.acr *.alg *.glg *.glo *.gls *.glsdefs *.fls *.log *.nav *.fdb_latexmk *.run.xml *.snm *.spl *.synctex.gz *.vrb *.pyg *.snippets && rm -rf cache'
          alias texb="latexmk -interaction=nonstopmode -pdf -lualatex -pretex='\\pdfvariable suppressoptionalinfo 512\\relax' -usepretex -shell-escape && texclean"
        '';
      };
    }
  );
}
