{
  description = "nixquad";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = _: {
    nixosModules = {
      nixquad = ./modules/nixos.nix;
    };
  };
}
