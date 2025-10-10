{pkgs, ...}: {
  environment.systemPackages = [
    (
      pkgs.wine-with-pcsclite.override {
        wineBuild = "wineWow64";
      }
    )
    pkgs.winetricks-wow64
  ];

  nixpkgs.overlays = [
    (
      final: prev: {
        wine-with-pcsclite = prev.wine.overrideAttrs (old: {
          buildInputs = old.buildInputs ++ [final.pcsclite];
          configureFlags = old.configureFlags ++ ["--with-pcsclite"];
        });
        winetricks-wow64 = prev.winetricks.overrideAttrs (old: {
          patches = [
            (final.fetchpatch {
              # make WINE_BIN and WINESERVER_BIN overridable
              # see https://github.com/NixOS/nixpkgs/issues/338367
              url = "https://github.com/Winetricks/winetricks/commit/1d441b422d9a9cc8b0a53fa203557957ca1adc44.patch";
              hash = "sha256-AYXV2qLHlxuyHC5VqUjDu4qi1TcAl2pMSAi8TEp8db4=";
            })
          ];
          postInstall =
            old.postInstall
            + ''
              sed -i \
                -e '2i : "''${WINESERVER_BIN:=/run/current-system/sw/bin/wineserver}"' \
                -e '2i : "''${WINE_BIN:=/run/current-system/sw/bin/.wine}"' \
                "$out/bin/winetricks"
            '';
        });
      }
    )
  ];
}

