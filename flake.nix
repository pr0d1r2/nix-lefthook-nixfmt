{
  description = "Lefthook-compatible nixfmt formatter check packaged as a Nix flake";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting = {
      url = "github:pr0d1r2/set-and-setting";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-lock.follows = "nixpkgs-lock";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    (
      consumer:
      consumer
      // {
        # The standard devShells carry only the lefthook-* wrappers; the
        # unit suite also runs raw shellcheck against every script.
        devShells = builtins.mapAttrs (
          system: shells:
          builtins.mapAttrs (
            _name: shell:
            shell.overrideAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [
                nixpkgs.legacyPackages.${system}.shellcheck
              ];
            })
          ) shells
        ) consumer.devShells;
      }
    )
      (
        set-and-setting.lib.mkConsumerFlake {
          inherit self nixpkgs set-and-setting;
          fragments = [
            "base"
            "nix"
            "shell"
            "ascii"
            "markdown"
            "yaml"
          ];
          src = ./.;
          extraPackages = pkgs: {
            default = pkgs.writeShellApplication {
              name = "lefthook-nixfmt";
              runtimeInputs = [ pkgs.nixfmt ];
              text = builtins.readFile ./lefthook-nixfmt.sh;
            };
          };
          extraChecks = pkgs: {
            unit = pkgs.runCommand "unit-tests" {
              BATS_LIB_PATH = "${
                pkgs.symlinkJoin {
                  name = "bats-libraries";
                  paths = with pkgs.bats.libraries; [
                    bats-assert
                    bats-support
                  ];
                }
              }/share/bats";
              projectSrc = ./.;
              nativeBuildInputs = [
                pkgs.bats
                pkgs.git
                pkgs.nixfmt
                pkgs.shellcheck
                self.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
            } (builtins.readFile ./scripts/unit-tests.sh);
          };
        }
      );
}
