module GocongressNotifier
  def self.use_exception_notifier_middleware config
    config.middleware.use ExceptionNotifier,
      sender_address: 'usgcwebsite@gmail.com',
      exception_recipients: 'jared@jaredbeck.com'
  end
end
