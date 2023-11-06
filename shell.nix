{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
	buildInputs = with pkgs; [
		texlive.combined.scheme-full
		(gomplate.override { buildGoModule = buildGo120Module; })
	];
}
