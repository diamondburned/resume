{ pkgs ? import <nixpkgs> {} }:

let
	lib = pkgs.lib;

	gomplate = pkgs.gomplate.override {
		# https://github.com/NixOS/nixpkgs/issues/264441
		# buildGoModule = pkgs.buildGo120Module;
	};
in

pkgs.mkShell {
	buildInputs = with pkgs; [
		git-crypt
		gomplate
		tectonic
		texliveMinimal
	];
}
