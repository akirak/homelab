{
  services.ollama = {
    enable = true;
    loadModels = [
      "mistral"
      "deepseek-r1:1.5b"
    ];
    # /var/lib/private should be on a persistent file system
  };
}
