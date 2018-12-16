{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [

    (haskellPackages.ghcWithPackages (
      pkgs: with pkgs; [
        # For Control.Conditional
        cond
        turtle
      ]))

    entr
    haskellPackages.turtle

    stack

    ];
  }
