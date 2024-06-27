{
  description = "Example JavaScript development environment for Zero to Nix";

  # Flake inputs
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2305.491812.tar.gz";
    nixpkgs.url = "github:NixOS/nixpkgs?rev=2726f127c15a4cc9810843b96cad73c7eb39e443";
  };

  # Flake outputs
  outputs = {
    self,
    nixpkgs,
  }: let
    # Systems supported
    allSystems = [
      "x86_64-linux" # 64-bit Intel/AMD Linux
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-darwin" # 64-bit Intel macOS
      "aarch64-darwin" # 64-bit ARM macOS
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    # Development environment output
    devShells = forAllSystems ({pkgs}: {
      default = pkgs.mkShell {
        # The Nix packages provided in the environment
        packages = with pkgs; [
          nodejs_20 # Node.js 18, plus npm, npx, and corepack
          ### https://github.com/prisma/prisma/discussions/3120
          nodePackages_latest.pnpm
          nodePackages_latest.vercel
          nodePackages_latest.prisma
          postgresql_15
          openssl
          prisma-engines
          # nodePackages.pnpm
        ];
        env = {
          PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
          PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
          PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
        };
      };
    });
  };
}
