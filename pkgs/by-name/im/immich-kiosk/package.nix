{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nodejs,
}:

buildGoModule (finalAttrs: {
  pname = "immich-kiosk";
  version = "0.39.3";

  src = fetchFromGitHub {
    owner = "damongolding";
    repo = "immich-kiosk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kdTEvH8MqL3oXe0QZlPTVpeByLpqAdNfPGfu5f2G6g0=";
  };

  # Delete vendor directory to regenerate it consistently across platforms
  postPatch = ''
    rm -rf vendor
  '';
  vendorHash = "sha256-y6Xl00G+mkhRKVGwMS0WCXZhQqqGGX5qY8PhMxtw7z8=";
  proxyVendor = true;

  # Frontend is in a subdirectory
  pnpmRoot = "frontend";

  nativeBuildInputs = [
    nodejs
  ];

  # Generate templ templates and build frontend assets before Go build
  # Frontend assets are embedded into the binary via go:embed
  preBuild = ''
    go run github.com/a-h/templ/cmd/templ generate

    pushd frontend
    popd
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  # Tests require network access to an Immich server
  doCheck = false;

  meta = {
    description = "Lightweight slideshow for running on kiosk devices and browsers that uses Immich as a data source";
    longDescription = ''
      Immich Kiosk is a lightweight slideshow for running on kiosk devices and
      browsers that uses Immich as a data source. It displays photos and videos
      from your Immich server in a configurable slideshow format, perfect for
      digital photo frames and kiosk displays.

      This is not an official Immich project and is not affiliated with Immich.
    '';
    homepage = "https://github.com/damongolding/immich-kiosk";
    changelog = "https://github.com/damongolding/immich-kiosk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ tlvince ];
    mainProgram = "immich-kiosk";
  };
})
