{ pkgs ? import <nixpkgs> {} }:

let
	gomplate = pkgs.gomplate.override {
		# https://github.com/NixOS/nixpkgs/issues/264441
		# buildGoModule = pkgs.buildGo120Module;
	};
in

pkgs.mkShell {
	buildInputs = with pkgs; [
		git-crypt
		gomplate
		texlive.combined.scheme-full
	];
}
