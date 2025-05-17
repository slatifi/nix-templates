{
  description = "A flake to edit Juypter notebooks in Neovim";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/staging-next";

    flake-utils.url = "github:numtide/flake-utils";

    nvim = {
      url = "github:slatifi/nvim-config";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, nvim, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {inherit system; config.allowBroken = true;};
  in
  {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        neovim
        imagemagick
        python312
        python312Packages.pip
        python312Packages.jupyter
        python312Packages.jupytext
        python312Packages.pynvim
        python312Packages.pandas
        python312Packages.matplotlib
        lua51Packages.magick
        lua51Packages.luarocks
      ];

      shellHook = ''
        export PATH=$PATH:${pkgs.neovim}/bin
        ln -s ${nvim} ~/.config/nvim-jupyter
        export NVIM_APPNAME=nvim-jupyter
        alias nvim="nvim -c 'let g:python3_host_prog=\"${pkgs.python312}/bin/python\"'"
        trap 'rm ~/.config/nvim-jupyter' EXIT
      '';
    };
  });
}
