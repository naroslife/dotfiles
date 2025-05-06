{
  description = "naroslife's Home Manager configuration";

  inputs = {
    # Pin Nixpkgs for reproducibility
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Or choose a specific release branch

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs version
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux"; # Adjust if your architecture is different
      pkgs = nixpkgs.legacyPackages.${system};
      # Extend nixpkgs.lib with home-manager.lib
      extendedLib = nixpkgs.lib.extend (self: super: home-manager.lib);
      username = "uif58593"; # CHANGE THIS if your username is different
    in
    {
      # Define the home-manager configuration for your user
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          lib = extendedLib;       # Nixpkgs library
        };

        # Specify the modules to import, including your custom config
        modules = [
          ./home.nix # Your main configuration file
        ];
      };

      # Define a default package or devShell
      # packages.${system}.default = pkgs.mkShell {
      #   name = "dotfiles-env";
      #   buildInputs = [ pkgs.git pkgs.nix ];
      # };

      # Optionally, set a defaultPackage for convenience
      # defaultPackage.${system} = self.packages.${system}.default;

      # You could also define devShells, packages, etc. here if needed
      # Example devShell:
      # devShells.${system}.default = pkgs.mkShell {
      #   name = "dotfiles-env";
      #   buildInputs = [ pkgs.git pkgs.nix ];
      # };
    };
}