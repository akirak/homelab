{
  services.rabbitmq = {
    enable = true;

    # These values are the default, but set explicitly to ensure the service is
    # private.
    listenAddress = "127.0.0.1";
  };
}
