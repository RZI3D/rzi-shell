{
  description = "RZI QS Shell";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    homeManagerModules.default = { ... }: {
      xdg.configFile."quickshell/rzi".source = self;
    };
  };
}
