{ lib, ... }:
{
  enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  unsupportedServiceKeys = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  user = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  quadlets = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
}
