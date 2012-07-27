# upload.rb

# para arrancar
# gem install sinatra
# ruby -rubygems myapp.rb

require 'sinatra'
require 'fileutils'
require 'data_mapper'

html_path = '/srv/http/rockola/files' #hard links to /srv/media
#html_path = '/srv/http/rockola/files/$user' caundo tenemos sessiones
store_path = '/srv/media' #git-media store media files

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/rock.db")

class File 
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :md5,         String, :required => true
  property :type,         String, :required => true
  property :path,         String, :required => true
  property :size,         String, :required => true
  property :user,         String, :required => true
  property :completed_at, DateTime
end
DataMapper.finalize

post '/upload' do

   md5 = params['file.md5']
   name = params['file.name']
   type = params['file.content_type']
   path = params['file.path']  
   size = params['file.size']
   submit = params['submit']
   
  # imitar git-media
  FileUtils.cp("#{path}", "#{store_path}/#{md5}")
  FileUtils.ln("#{store_path}/#{md5}", "#{html_path}/#{name}")
  
  path = "#{html_path}/#{name}"
  File.create(name: name, md5: md5, type: type, path: path, size: size, user: user)
  
   # imprimir valores (debug) 
   #puts "{ name: #{name}, path: #{path}, type: #{type}, md5: #{md5}, size: #{size}, submit: #{submit} }"

end


