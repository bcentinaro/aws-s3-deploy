require "deploy/version"
require 'aws-sdk'
require 'yaml'


module Deploy
  
  def self.load_config
    defaults = {'aws_region' => 'us-west-2'}
    @config = YAML.load_file("#{Dir.pwd}/.deploy")
    @config = defaults.merge(@config)
  end
  
  def self.create_config(config = {})  
    config = {
      'aws_key' =>  nil,
      'aws_secret' =>  nil, 
      'aws_bucket' => nil, 
      'deploy_folder' =>  nil
    }.merge(config)
    File.open("#{Dir.pwd}/.deploy", 'w+') { |file| file.write(config.to_yaml) }
  end
  
  def self.get_bucket
    ::AWS.config(access_key_id: @config['aws_key'], secret_access_key: @config['aws_secret'], region: @config['aws_region'])
    service = ::AWS::S3.new(s3_endpoint: "s3-#{@config['aws_region']}.amazonaws.com")
    service.buckets[@config['aws_bucket']]
  end
  
  def self.sync
    bucket = get_bucket
    Dir.glob("#{@config['deploy_folder']}/**/*").each do |file|

      if File.file?(file)
        remote_file = file.sub("#{@config['deploy_folder']}/", "")
          puts "+ #{file}"
          remote = bucket.objects[remote_file]
          
          content_type = case file.split('.').last
          when 'css'
            'text/css'
          when 'js'
             'application/javascript'
          when 'otf'
            'font/opentype'
          when 'svg'
            'image/svg+xml'
          end 
          if File.exist?("#{file}.gz")
            remote.write(file: "#{file}.gz", content_encoding: 'gzip',  content_type: content_type)
          else
            remote.write(file: file,  content_type: content_type)
          end
          remote.acl = :public_read 
      end
    end
  end
end
