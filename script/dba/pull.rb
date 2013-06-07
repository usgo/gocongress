#!/usr/bin/env ruby

class Puller

  def initialize args
    die(usage) unless args.length == 2
    @app_name = args[0]
    @local_db_name = args[1]
  end

  def capture
    unless system "heroku pgbackups:capture --expire --app #{@app_name}"
      die "Unable to capture a backup"
    end
  end

  def die msg
    $stderr.puts msg
    exit($?.to_i || 1)
  end

  def download
    %x{curl -o tmp/latest.dump `heroku pgbackups:url --app #{@app_name}`}
    unless $?.success?
      die "Unable to download the backup"
    end
  end

  def restore
    opts = "--verbose --clean --no-acl --no-owner"
    unless system "pg_restore #{opts} -d #{@local_db_name} tmp/latest.dump"
      die "Restore failed"
    end
  end

  def pull
    capture
    download
    restore
  end

  def usage
    "Usage: pull.rb app_name local_db_name"
  end
end

Puller.new(ARGF.argv).pull
