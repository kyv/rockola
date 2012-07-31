# upload.rb

# para arrancar
# gem install sinatra
# ruby -rubygems upload.rb

require 'sinatra'
require 'fileutils'
require 'data_mapper'

html_path = '/tmp/http/rockola/files' #hard links to /srv/media
#html_path = '/srv/http/rockola/files/$user' caundo tenemos sessiones
store_path = '/tmp/media' #git-media store media files

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/rock.db")

class Media
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :md5,          String, :required => true
  property :type,         String, :required => true
  property :path,         String, :required => true
  property :size,         String, :required => true
#  property :user,         String, :required => true
  property :created_at, DateTime
end
DataMapper.finalize
Media.auto_upgrade!

post '/upload' do

   md5 = params['file.md5']
   name = params['file.name']
   type = params['file.content_type']
   path = params['file.path']
   size = params['file.size']
   submit = params['submit']

  # imprimir valores (debug) 
  puts "{ name: #{name}, path: #{path}, type: #{type}, md5: #{md5}, size: #{size}, submit: #{submit} }"
  store = store_path + "/" + md5

  if File.exists? store 
    'File Exists'

  else
  # imitar git-media
  FileUtils.cp("#{path}", store)
  FileUtils.ln(store, "#{html_path}/#{name}")
  
  finpath = "#{html_path}/#{name}"
  #File.create(name: name, md5: md5, type: type, path: path, size: size, user: user)
  Media.create(name: name, md5: md5, type: type, path: finpath, size: size)
  end

end

get '/media' do
    # get the latest 20 posts
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_html
end

get '/media_json' do
    # get the latest 20 posts
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_json

end
