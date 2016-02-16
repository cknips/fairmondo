#   Copyright (c) 2012-2016, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

# Config Redis

# This code is responsible for loading the sidekiq-pro gem, which is NOT installed
# via bundler
begin
  file = YAML.load_file("#{Rails.root}/config/sidekiq_pro_path.yml")
  path = file['path']
  $LOAD_PATH.unshift(path)
rescue
  puts 'sidekiq_pro_path.yml not found'
end

begin
  require 'sidekiq-pro'
  require 'sidekiq/pro/reliable_push'
rescue LoadError
end



if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV["REDIS_PROVIDER"] }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV["REDIS_PROVIDER"] }
    begin
      require 'sidekiq/pro/reliable_fetch'
    rescue LoadError
    end
  end
end



Redis.current = SidekiqRedisConnectionWrapper.new
