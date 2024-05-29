{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ]
          (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        # inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            wabt # conversion between wat <-> wasm
            dart
            gtk3
            pkg-config
            flutter
            wasmer
          ];
        };
      });
    };
}
