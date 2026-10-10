{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		mangowm = {
			url = "github:mangowm/mango";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		mangobar = {
			url = "github:mangowm/mangobar";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixvim = { 
		    url = "github:nix-community/nixvim";
	            inputs.nixpkgs.follows = "nixpkgs";
		    # If you are not running an unstable channel of nixpkgs, select the corresponding branch of Nixvim.
		    # url = "github:nix-community/nixvim/nixos-25.11";
		};
	};

	outputs = { nixpkgs, mangowm, mangobar, nixvim, ... } @ inputs: 
	let
    user = "jex";
		system = "x86_64-linux";
		pkgs = import nixpkgs { inherit system; };
		nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
		inherit pkgs;
	};
	in {
		packages.${system}.default = nvim;

		checks.${system}.default = nixvim.lib.${system}.check.mkTestDerivationFromNvim {
		inherit nvim;
		name = "A nixvim configuration";
		};
 	
		nixosConfigurations.nix-desk = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			modules = [
				./configuration.nix
				# renaming mangowm to mango
				inputs.mangowm.nixosModules.mango
				inputs.nixvim.nixosModules.nixvim
				# other imports
			];
    };
  };
}
