{
  description = "naroslife's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
  };

  outputs = { self, nixpkgs, home-manager, nur, flake-utils, nixpkgs-wayland, ... }:
    let
      system = builtins.currentSystem or "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur.overlay
          nixpkgs-wayland.overlay
        ];
      };

      # List all supported users here
      users = [ "naroslife" "uif58593" ]; # Add more usernames as needed

      mkHomeConfig = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          nur.modules.homeManager.default
        ];
        extraSpecialArgs = {
          nurPackages = nur.packages.${system};
          waylandPackages = nixpkgs-wayland.packages.${system};
          username = username;
          homeDirectory = "/home/${username}";
          gitUserName = username;
          gitUserEmail = (if username == "naroslife" then "robi54321@gmail.com" else "robert.4.nagy@aumovio.com");
        };
      };
    in
    {
      homeConfigurations = builtins.listToAttrs (
        map (u: { name = u; value = mkHomeConfig u; }) users
      );

      packages.${system} = {
        nur-example = nur.packages.${system}.dog;
        wayland-example = nixpkgs-wayland.packages.${system}.wl-clipboard;
      };
    };
}