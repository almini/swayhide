{
  description = "swayhide - A window swallower for sway";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = inputs:
    with inputs;
    let
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      config = system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        swayhide = pkgs.rustPlatform.buildRustPackage rec {
          pname = "swayhide";
          version = "0.2.1";
          src = ./.;
          useFetchCargoVendor = true;
          cargoHash = "sha256-ng15mXfk3atT5/ELM47vpBneLZtzHdHDhCobrmlx3uQ=";
          nativeBuildInputs = with pkgs; [ installShellFiles ];

          postInstall = ''
            installShellCompletion \
              --name ${pname} completions/swayhide.bash \
              --name ${pname}.fish completions/swayhide.fish \
              --name _${pname} completions/swayhide.zsh
          '';
        };
      in {
        packages.${system}.default = swayhide;

        overlays.default = final: prev: {
          inherit swayhide;
        };

        devShells.${system}.default = pkgs.mkShell {
          buildInputs = with pkgs; [ rustc cargo rustfmt ];
        };
      };
    in builtins.foldl' (acc: system: acc // (config system)) { } systems;
}
