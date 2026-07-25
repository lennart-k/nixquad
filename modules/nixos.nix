{
  config,
  lib,
  pkgs,
  ...
}:

let
  utils = import (pkgs.path + "/nixos/lib/utils.nix") {
    inherit pkgs config lib;
  };
  inherit (utils.systemdUtils.lib) settingsToSections;
  cfg = config.virtualisation.nixquad;
  serviceGenerator = pkgs.buildGoModule {
    name = "quadlet-service-builder";
    vendorHash = "sha256-DjxjEnl9w43hrkYeDMBTQGO/JyJ/q1ekuZQglPw8CSE=";
    src = ../.;
  };
  unsupportedServiceKeysFlag = if cfg.unsupportedServiceKeys then "-unsupported-service-keys" else "";
in
{
  options.virtualisation.nixquad = import ./options.nix { inherit config lib pkgs; };

  config = lib.mkIf cfg.enable (
    let
      mapQuadletServiceName =
        quadletName:
        let
          m = builtins.match "^(.*)\\.([^.]+)$" quadletName; # null if no extension
        in
        if m == null then
          builtins.error ("no extension in: " + quadletName)
        else
          let
            base = builtins.head m;
            ext = builtins.head (builtins.tail m);
          in
          if ext == "container" then
            base + ".service"
          else if ext == "volume" then
            base + "-volume.service"
          else if ext == "kube" then
            base + ".service"
          else if ext == "network" then
            base + "-network.service"
          else if ext == "image" then
            base + "-image.service"
          else if ext == "artifact" then
            base + "-artifact.service"
          else if ext == "pod" then
            base + "-pod.service"
          else
            lib.builtins.throw ("unsupported extension: " + ext + " (input: " + quadletName + ")");

      quadletConfigs = lib.attrsets.mapAttrs (
        name: value: (pkgs.writeText name (settingsToSections value))
      ) cfg.quadlets;
      inputDir = pkgs.linkFarm "quadlet-inputs" quadletConfigs;

      # Returns a directory with all quadlet services
      quadletServices = pkgs.stdenv.mkDerivation {
        name = "quadlet-services";
        src = ./.;
        nativeBuildInputs = [
          serviceGenerator
          pkgs.podman
        ];

        buildPhase = ''
          mkdir -p "$out"
          PODMAN="${config.virtualisation.podman.package}/bin/podman" ${serviceGenerator}/bin/cmd ${unsupportedServiceKeysFlag} -input "${inputDir}" -output "$out"
        '';
      };
    in
    {
      systemd.units = lib.listToAttrs (
        lib.attrsets.mapAttrsToList (name: value: {
          name = mapQuadletServiceName name;
          value = {
            text = builtins.readFile "${quadletServices}/${mapQuadletServiceName name}";
          }
          // (builtins.fromJSON (builtins.readFile "${quadletServices}/${mapQuadletServiceName name}.json"));
        }) quadletConfigs
      );
    }
  );
}
