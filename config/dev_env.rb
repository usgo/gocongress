module GocongressDevelopmentEnv

  def self.load_env
    return unless local_development?
    if env_file_exists?
      load_constants_from_env_file
      apply_constants_to_global_env
      check_for_expected_constant_in_global_env
    else
      $stderr.puts 'Warning: File not found: .env (see the gocongress readme)'
    end
  end

  def self.apply_constants_to_global_env
    constants.each do |c|
      ENV[c.to_s] = const_get(c, false)
    end
  end

  def self.load_constants_from_env_file
    begin
      module_eval File.read env_file
    rescue SyntaxError => se
      $stderr.puts "Warning: Syntax error in file: #{env_file}"
      $stderr.puts se.to_s
    end
  end

  def self.env_file
    '.env'
  end

  def self.env_file_exists?
    File.file? env_file
  end

  def self.local_development?
    ['development', 'test'].include?(Rails.env)
  end

  def self.check_for_expected_constant_in_global_env
    if ENV['GMAIL_SMTP_USER'].blank?
      $stderr.puts "Warning: ENV['GMAIL_SMTP_USER'] undefined"
    end
  end
end
