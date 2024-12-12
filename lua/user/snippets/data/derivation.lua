-- Templates for basic derivations
--

local derivations = {}

derivations.basic = [[
# default.nix
# 
# 
let
  pkgs = import <nixpkgs> { };
in
derivation {
  name = "<<<<SNIPPET_EJOVO_NODE>>>>";
  builder = "${pkgs.bash}/bin/bash";
  # Requires that a ./build.sh is in the current directory
  args = [ ./build.sh ];
  inherit (pkgs) gcc coreutils;
  src = ./.;
  system = builtins.currentSystem;
}]]

return derivations
