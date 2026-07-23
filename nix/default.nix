{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:
buildDotnetModule rec {
  pname = "octo-fiesta";
  version = "0.10";
  src = fetchFromGitHub {
    repo = "octo-fiesta";
    owner = "V1ck3s";
    tag = "v${version}";
    sha256 = "sha256-1DMx+PLK9Lxhf052meovrvgya/8WP7YngQjQqwyxOos=";
  };

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

  meta = {
    mainProgram = "octo-fiesta";
  };
}
