{
  services.recoll.settings = {
    followLinks = true;

    # TODO: Add support for extra (private) top directories
    topdirs = [
      "~/resources/bundles"
      "~/resources/ebooks"
      "~/resources/sound"
      "~/resources/bundles"
    ];

    excludedmimetypes = [
      "text/html"
      "application/x-mobipocket-ebook"
      "audio/flac"
    ];
  };
}
