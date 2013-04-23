require 'yaml'
require 'open-uri'
require 'pathname'
require 'json'
require 'net/https'
require 'net/http/post/multipart'

module GetLocalization
  class Project
    def initialize(path)
      yaml = YAML.load_file(path)
      @username = yaml['username']
      @password = yaml['password']
      @project = yaml['project']
      @files = yaml['files'] || {}

      # no is likely to mean Norwegian to us, but in YAML it means false if
      # you forget to quote it. People are going to forget, help them out.
      @files.each do |master_file, obj|
        if obj.has_key? false
          obj['no'] = obj.delete(false)
        end
      end
    end

    attr_writer :username, :password
    attr_reader :files

    def master_files
      unless @master_files
        request = open_request("https://api.getlocalization.com/#{@project}/api/list-master/json/")
        obj = JSON.parse(request.read)
        @master_files = obj['success'] == '1' ? obj['master_files'] : nil
      end
      @master_files
    end

    def translations
      unless @translations
        request = open_request("https://api.getlocalization.com/#{@project}/api/translations/list/json/")
        @translations = JSON.parse(request.read)
      end
      @translations
    end

    def translation_info
      info = Hash.new {|h,k| h[k] = Hash.new {|m,n| m[n] = Hash.new {|p,q| p[q] = Hash.new }}}
      master_files.each do |master_file|
        info[master_file]
      end

      translations.each do |translation|
        if info.has_key? translation['master_file']
          info[translation['master_file']][translation['iana_code']] = {
            :server => true,
            :progress => translation['progress']
          }
        end
      end

      @files.each do |master_file, obj|
        if info.has_key? master_file
          obj.each do |lang, path|
            info[master_file][lang][:local_path] = path
          end
        end
      end

      info
    end

    def download(master_file, lang)
      local_path = @files[master_file][lang]
      Pathname.new(local_path).parent.mkpath
      File.open(local_path, "wb") do |out_file|
        request = open_request("https://api.getlocalization.com/#{@project}/api/translations/file/#{master_file}/#{lang}/")

        # For at least some iOS files, the encoding will be messed and treated
        # as ASCII even though it's actually UTF-16. Make a modest effort at
        # detecting UTF-16 streams and force the encoding. Actually use UTF-8
        # for the downloaded file though.
        first_byte = request.readbyte
        request.rewind
        if first_byte >= 0xfe
          request.set_encoding('UTF-16', 'UTF-8')
        end

        request.each_line do |line|
          # TODO: This is a hack because Get Localization incorrectly escapes apostrophes in JSON.
          # Hopefully GL will fix the issue, but if we really do need this we should probably be a bit more
          # careful than this gsub.
          # We also sometimes have translators accidentally insert a tab and GL doesn't escape
          # the tab, resulting in invalid JSON. To get valid JSON we could replace it with \t,
          # but so far there's no scenario where we want a tab, so we just remove them.
          if local_path.end_with?('json')
            line = line.gsub(/\\'/, "'").gsub(/\t/, "")
          end

          out_file.write(line)
        end
      end
    end

    def upload(master_file)
      local_path = @files[master_file]['master']
      url = URI.parse("https://api.getlocalization.com/#{@project}/api/update-master/")
      success = false
      File.open(local_path) do |f|
        request = Net::HTTP::Post::Multipart.new url.path, "file" => UploadIO.new(f, "text/plain", master_file)
        request.basic_auth @username, @password
        conn = Net::HTTP.new(url.host, url.port)
        conn.use_ssl = url.scheme == 'https'
        response = conn.start do |http|
          http.request(request)
        end
        success = response.code == '200'
      end
      success
    end

    def has_credentials?
      @username and @password
    end

    def has_username?
      not @username.nil?
    end

    def has_password?
      not @password.nil?
    end

    private

    def open_request(uri)
      open(uri, :http_basic_authentication => [@username, @password])
    end
  end
end
