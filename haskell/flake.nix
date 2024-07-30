{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat/master";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
          ]
          (
            system:
            f (
              import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [ ];
              }
            )
          );
    in
    {
      formatter = eachSystem (pkgs: pkgs.nixfmt-rfc-style);
      packages = eachSystem (pkgs: {
        default = pkgs.haskellPackages.callCabal2nix "proj" (pkgs.lib.cleanSource ./.) { };
      });
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.system}.default.env ];
          packages =
            (with pkgs; [ haskell-language-server ])
            ++ (with pkgs.haskellPackages; [
              cabal-fmt
              cabal-install
              fourmolu
              ghcid
              hlint
            ]);
        };
      });
    };
}
