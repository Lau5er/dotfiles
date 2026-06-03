{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    snapmaker-orca = {
      url = "github:Lau5er/nix-snapmaker-orca";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, nix-vscode-extensions, plasma-manager, snapmaker-orca, ... }:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      vscode-extensions = nix-vscode-extensions.extensions.${system};

    in
    {
      nixosConfigurations.nix-pad = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable; };
        modules = [
          ./profile/nix-pad/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lauser = import ./profile/nix-pad/home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit pkgs-unstable vscode-extensions; };
            };
          }
        ];
      };
      
      nixosConfigurations.brobook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable; };
        modules = [
          ./profile/brobook/configuration.nix
          home-manager.nixosModules.home-manager
          snapmaker-orca.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lauser = import ./profile/brobook/home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit pkgs-unstable vscode-extensions plasma-manager; };
            };
          }
          ({ pkgs, ... }: {
            programs.snapmaker-orca = {
              enable = true;
              package = pkgs.symlinkJoin {
                name = "snapmaker-orca";
                paths = [ snapmaker-orca.packages.${system}.snapmaker-orca ];
                buildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/snapmaker-orca \
                    --set LC_ALL C.UTF-8 \
                    --set LANG C.UTF-8
                '';
              };
            };
          })
        ];
      };

      nixosConfigurations.nix-gaming = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable; };
        modules = [
          ./profile/nix-gaming/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lauser = import ./profile/nix-gaming/home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit pkgs-unstable vscode-extensions; };
            };
          }
        ];
      };
    };
}
