{
  description = "FracturedStack NixOS configuration";

  
  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };



  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = { 
      url = "github:Gerg-L/spicetify-nix";
    };
  };




  outputs = { self, nixpkgs, home-manager, noctalia, spicetify-nix, ... } @ inputs: {
    nixosConfigurations.FracturedStack = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./noctalia.nix
        ./spicetify.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };



}
