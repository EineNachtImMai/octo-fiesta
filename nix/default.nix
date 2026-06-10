{
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule {
  pname = "octo-fiesta";
  version = "0.9";
  src = ../.;

  doCheck = true;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;

  projectFile = "octo-fiesta.sln";

  /*
  to generate / update this file:
  - `nix build .#default.fetch-deps`
  - `./result deps.json`
  - `rm result`

  alternatively, if this isn't working, you can do it manually:
  - go to the project's root directory
  - `dotnet restore --packages tmpDir`
  - `nuget-to-json out > deps.json`
  - `rm -r tmpDir`

  source: https://nixos.org/manual/nixpkgs/unstable/#dotnet
  */
  nugetDeps = ../deps.json;
}
