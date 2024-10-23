{
  description = "wasm-bindgen-webassembly-global-test-case";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = toolchain:
          let
            rustToolchain = pkgs.rust-bin.${toolchain}.latest.default.override {
              targets = [
                "wasm32-wasip1"
                "wasm32-unknown-unknown"
              ];
            };
          in
          if builtins.hasAttr toolchain pkgs.rust-bin then
            rustToolchain
          else
            throw "Unsupported Rust toolchain: ${toolchain}";

        wasm-bindgen-cli = with pkgs; rustPlatform.buildRustPackage
          rec {
            pname = "wasm-bindgen-cli";
            version = "0.2.95";
            buildInputs = [ pkgs.rust-bin.stable.latest.default ] ++ lib.optionals stdenv.isDarwin [
              darwin.apple_sdk.frameworks.SystemConfiguration
              darwin.apple_sdk.frameworks.Security
            ];

            src = pkgs.fetchCrate {
              inherit pname version;
              sha256 = "sha256-prMIreQeAcbJ8/g3+pMp1Wp9H5u+xLqxRxL+34hICss=";
            };

            cargoHash = "sha256-6iMebkD7FQvixlmghGGIvpdGwFNLfnUcFke/Rg8nPK4=";
          };

        rust-toolchain = rustToolchain "stable";
      in
      {
        devShells.default = with pkgs;
          mkShell {
            buildInputs = [
              binaryen
              pkg-config
              rust-toolchain
              wasm-bindgen-cli
              wasm-tools
              wayland
            ] ++ lib.optionals stdenv.isLinux [
              chromium
              chromedriver
            ];
          };
      }
    );
}
