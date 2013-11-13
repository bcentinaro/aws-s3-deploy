require "aws/s3/deploy/version"

module Aws
  module S3
    module Deploy
      def create_config
        config = {
          aws_key: nil,
          aws_secret: nil, 
          aws_bucket: nil, 
          deploy_folder: nil
        }
        File.open('./.deploy.yml', 'w+') { |file| file.write(config.to_yml) }
  
      end
    end
  end
end
