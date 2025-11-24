{ system ? builtins.currentSystem
, overlays ? [ ]
}:

let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
    sha256 = lock.nodes.nixpkgs.locked.narHash;
  };
  
  nixAiToolsSrc = fetchTarball {
    url = "https://github.com/numtide/nix-ai-tools/archive/${lock.nodes.nix-ai-tools.locked.rev}.tar.gz";
    sha256 = lock.nodes.nix-ai-tools.locked.narHash;
  };
  
  nixpkgs = import nixpkgsSrc {
    inherit system;
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import "${nixAiToolsSrc}/overlay.nix")
    ] ++ overlays;
  };
in
nixpkgs