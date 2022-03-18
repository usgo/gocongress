CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS', # required
    aws_access_key_id: ENV.fetch('AWS_UPLOADER_KEY_ID'), # required unless using use_iam_profile
    aws_secret_access_key: ENV.fetch('AWS_UPLOADER_ACCESS_KEY'), # required unless using use_iam_profile
    region: ENV.fetch('AWS_S3_REGION')
  }

  config.fog_directory = ENV.fetch('AWS_S3_BUCKET') # required
  config.fog_public = false

  # For testing, upload files to local `tmp` folder.
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp"
  else
    config.storage = :fog
  end

  config.cache_dir = "#{Rails.root}/tmp/uploads" # To let CarrierWave work on heroku
end
