{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use. 
  # As of 2024-11-14 we can use 24.05 for Go # 1.22.8
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs =
    { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      # # A Nixpkgs overlay.
      # overlay = final: prev: {
      #   go = final.go_1_20;
      #   buildGoModule = final.buildGo117Module;
      # };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {

          caddy = pkgs.buildGoModule {
            pname = "caddy";
            inherit version;
            src = ./caddy-src;
            runVend = true;
            vendorHash = "sha256-o5s3i+HArqXcmnhmpnnm1qEKmU/UeYii13Qoj5nP39A=";
            # vendorHash = pkgs.lib.fakeSha256;

          };
        }
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.caddy);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ go ];
          };
        }
      );

    };
}
