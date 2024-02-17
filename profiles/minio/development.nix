{
  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    rootCredentialsFile = "/persist/minio-root-credentials";
  };
}
