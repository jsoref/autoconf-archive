/* Build instructions for the continuous integration system Hydra. */

{ autoconfArchiveSrc ? { outPath = ./.; }, officialRelease ? false }:

let

  pkgs = import <nixpkgs> { };

  version = "2013.02.02";
  versionSuffix = if officialRelease then "" else "-dirty";

in

rec {

  tarball = pkgs.releaseTools.sourceTarball {
    name = "autoconf-archive-tarball";
    src = autoconfArchiveSrc;
    inherit version versionSuffix officialRelease;
    buildInputs = with pkgs; [ git perl texinfo python lzip texLive ];
    postUnpack = ''
      cp -r ${pkgs.gnulib}/ gnulib/
      chmod -R u+w gnulib
      patchShebangs gnulib
    '';
    distPhase = ''
      make -j$NIX_BUILD_CORES maintainer-all all
      make distcheck
      mkdir $out/tarballs
      mv -v autoconf-archive-*.tar* $out/tarballs/
    '';
  };

  build = { system ? "x86_64-linux" }: pkgs.releaseTools.nixBuild {
    name = "autoconf-archive-${version}${versionSuffix}";
    src = tarball;
  };

}
