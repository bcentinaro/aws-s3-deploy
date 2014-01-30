require "deploy/version"
require 'closure-compiler'
require 'aws-sdk'
require 'yaml'


module Deploy
  
  def self.load_config
    
    # We need to account for AWS Keys stored in 
    # ENV Variables here.
    defaults = {'aws_region' => 'us-west-2', 'compress' => true}
    @config = YAML.load_file("#{Dir.pwd}/.deploy")
    @config = defaults.merge(@config)
  end
  
  def self.create_config(config = {})  
    config = {
      'aws_key' =>  nil,
      'aws_secret' =>  nil, 
      'aws_bucket' => nil, 
      'deploy_folder' =>  nil,
      'compress' => true
    }.merge(config)
    config['aws_key'] = ENV['AWS_KEY'] if config['aws_key'].empty?
    config['aws_secret'] = ENV['AWS_SECRET'] if config['aws_secret'].empty?
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
          
          remote = bucket.objects[remote_file]
          
          content_type = case file.split('.').last
          when 'css'
            Deploy::Compress.compress(file)
            'text/css'
          when 'js'
            Deploy::Compress.compile(file)
            'application/javascript'
          when 'otf'
            'font/opentype'
          when 'svg'
            'image/svg+xml'
          when 'xml'
            'text/xml'
          when 'html', 'htm'
            'text/html'
          when 'gz'
            'skip'
          end 
          
          unless content_type == 'skip'
            if File.exist?("#{file}.gz")
              puts "+ #{file} (compressed)"
              remote.write(file: "#{file}.gz", content_encoding: 'gzip',  content_type: content_type)
            else
              puts "+ #{file}"
              remote.write(file: file,  content_type: content_type)
            end
            remote.acl = :public_read 
          end
      end
    end
  end
end


module Deploy::Compress
  def self.compress(file)
    content = File.read(file).encode!('UTF-8', 'UTF-8', :invalid => :replace) 
    gzip(content, file)
  end
  
  def self.compile(file)
    content = File.read(file).encode!('UTF-8', 'UTF-8', :invalid => :replace) 
    content = closure(content, file)
    gzip(content, file)
  end
  
  def self.gzip(content, file)
    Zlib::GzipWriter.open("#{file}.gz") {|f| f.write(content) }
  end
  
  def self.closure(content, file)
    Closure::Compiler.new.compile(content)
  end
end
