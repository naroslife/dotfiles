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
      username = "naroslife"; # CHANGE THIS if your username is different
    in
    {
      # Define the home-manager configuration for your user
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify the modules to import, including your custom config
        modules = [
          ./home.nix # Your main configuration file
          # You could add more modules here if needed
        ];

        # Optionally pass extra arguments to your modules
        # extraSpecialArgs = { ... };
      };

      # You could also define devShells, packages, etc. here if needed
      # Example devShell:
      # devShells.${system}.default = pkgs.mkShell {
      #   name = "dotfiles-env";
      #   buildInputs = [ pkgs.git pkgs.nix ];
      # };
    };
}