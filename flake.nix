{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs =
		{ self, nixpkgs, flake-utils }:

		flake-utils.lib.eachDefaultSystem (system:
			let
				pkgs = nixpkgs.legacyPackages.${system};
				deps = with pkgs; [
					gomplate
					tectonic
				];
			in
			{
				devShell = pkgs.mkShell {
					packages = deps ++ (with pkgs; [
						git-crypt      # for secrets
						texliveMinimal # for editor linting
					]);
				};
			}
		);
}
