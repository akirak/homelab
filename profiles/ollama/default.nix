{
  services.ollama = {
    enable = true;
    loadModels = [
      "mistral"
      "gemma3:4b"
      "phi4-mini"
    ];
    # /var/lib/private should be on a persistent file system
  };
}
