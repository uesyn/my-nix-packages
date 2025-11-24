{
  description = "Custom Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs =
    {
      nixpkgs,
      nix-ai-tools,
      ...
    }@inputs:
    let
      # Utility functions
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # AI tools overlay
      aiToolsOverlay = final: prev: {
        crush = nix-ai-tools.packages.${prev.system}.crush;
        code = nix-ai-tools.packages.${prev.system}.code;
        qwen-code = nix-ai-tools.packages.${prev.system}.qwen-code;
        opencode = nix-ai-tools.packages.${prev.system}.opencode;
        droid = nix-ai-tools.packages.${prev.system}.droid;
      };

      # Package configurations
      packagesForSystem =
        {
          system,
          overlays ? [ ],
        }:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ aiToolsOverlay ] ++ overlays;
        };

      formatterForSystem = system: (packagesForSystem { inherit system; }).nixfmt-tree;
    in
    {
      formatter = forAllSystems formatterForSystem;

      lib = nixpkgs.lib;

      legacyPackages = forAllSystems (
        system:
        packagesForSystem {
          inherit system;
          overlays = [ ];
        }
      );
    };
}
