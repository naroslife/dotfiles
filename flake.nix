{
  description = "naroslife's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR"; # Nix User Repository: community packages
    sops-nix.url = "github:Mic92/sops-nix"; # sops-nix: secret management
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland"; # Wayland packages
    nixpkgs-python.url = "github:nix-community/nixpkgs-python"; # Latest Python overlays
  };

  outputs = { self, nixpkgs, home-manager, nur, flake-utils, nixpkgs-wayland, nixpkgs-python, ... }:
    let
      system = builtins.currentSystem or "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur.overlay
          nixpkgs-wayland.overlay
          nixpkgs-python.overlay
        ];
            };

      # Automatically add current user to supported users
      currentUser = builtins.getEnv "USER";
      baseUsers = [ "naroslife" ];
      users = if currentUser != "" && !(builtins.elem currentUser baseUsers)
        then baseUsers ++ [ currentUser ]
        else baseUsers;

      # Helper to generate home configs for each user
      mkHomeConfig = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          nur.hmModules.nur
          # sops-nix.homeManagerModules.sops
          nixpkgs-wayland.homeManagerModules.default
          # Add more modules as needed
        ];
        # Optionally pass username/homeDirectory if needed
        # username = username;
        # homeDirectory = "/home/${username}";
        extraSpecialArgs = {
          nurPackages = nur.packages.${system};
          waylandPackages = nixpkgs-wayland.packages.${system};
          pythonPackages = nixpkgs-python.packages.${system};
        };
      };
    in
    {
      homeConfigurations = builtins.listToAttrs (
        map (u: { name = u; value = mkHomeConfig u; }) users
      );

      # Example: expose some useful packages from NUR, Wayland, overlays
      packages.${system} = {
        nur-example = nur.packages.${system}.dog;
        wayland-example = nixpkgs-wayland.packages.${system}.wl-clipboard;
        python-example = nixpkgs-python.packages.${system}.python311;
        node-example = nixpkgs-node.packages.${system}.nodejs_20;
      };
    };
}