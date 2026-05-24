{ lib, ... }:
{
  enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  quadlets = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
}
