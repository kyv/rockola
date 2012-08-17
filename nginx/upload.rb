# upload.rb

# para arrancar
# gem install sinatra
# ruby -rubygems upload.rb

require 'sinatra'
require 'fileutils'
require 'data_mapper'
require 'sinatra/flash'
require 'bcrypt'
require 'haml'
require 'taglib'
require 'json'
require 'open-uri'
require 'hpricot'

enable :sessions
#set :dump_errors, false
set :html_path, '/tmp/http/rockola/files' #hard links to /srv/media
set :store_path, '/tmp/media' #git-media store media files

DataMapper::Logger.new(STDOUT, :debug) #depurar db
# inicializar base de datos
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/rock.db")
class User
  include DataMapper::Resource
  property :id,           Serial, :key => true
  property :pass,          String, :required => true, length: 10..255 
  property :salt,          String, :required => true 
  property :email,         String, :required => true, :unique => true, format: :email_address 
  property :created_at, DateTime
  has n, :medias
end

class Media
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :md5,          String, :required => true, :key => true, :unique_index => true
  property :type,         String, :required => true
  property :path,         String, :required => true, :length => 150
  property :size,         String, :required => true
  property :title, 	  String, :length => 150
  property :artist, 	  String, :length => 150
  property :genre, 	  String, :length => 150
  property :duration, 	  String
  property :bitrate, 	  String
  property :channels, 	  String
  property :tags, 	  String, :length => 100
  property :created_at,   DateTime
  belongs_to :user
end

class Bara
  include DataMapper::Resource
  property :id,           Serial
  property :path,         String, :required => true
  property :playtime,     String, :required => true
  #has n, :medias
end

DataMapper.finalize
Media.auto_upgrade!
User.auto_upgrade!

helpers do
  def admin?
    if session[:login].nil? # or if session[:login] not in db
      return false
    else
      return true
    end
  end
  def login; return session[:login]; end
  def protected! ; halt [ 401, 'Not Authorized' ] unless admin? ; end
  def get_params(md5) ; return Media.all(:md5 => md5); end
end

post '/upload' do

   unless admin?
      redirect "/login"
   end

   email = session[:login]
   user = User.first(:email=>email)
   id = user.id
   if defined? params['file.md5']
     md5 = params['file.md5']
     name = params['file.name']
     type = params['file.content_type']
     path = params['file.path']
     size = params['file.size']
     submit = params['submit']
   end

   store = settings.store_path + "/" + md5
   finpath = settings.html_path + "/" + id.to_s + "/" + name

   unless File.exists? settings.store_path
      FileUtils.mkdir_p settings.store_path
   end 
   unless File.exists? "#{settings.html_path}/#{id.to_s}" 
      FileUtils.mkdir_p "#{settings.html_path}/#{id.to_s}"
   end 

   if File.exists? store 
     flash[:upload] = 'File Exists'
   else
     FileUtils.cp(path, store)
     FileUtils.ln(store, finpath)
     flash[:upload] = 'New file: ' + name
   end

   media_data = get_tags(finpath)
   genre = media_data[:genre][0..50]
   media_tags = "#{media_data[:artist]}, #{genre}"
   p media_tags
   Media.create(name: name, md5: md5, type: type, path: finpath, user_id: id, size: size, title: media_data[:title], artist: media_data[:artist], genre: genre, duration: media_data[:duration], channels: media_data[:channels], bitrate: media_data[:bitrate], tags: media_tags)
   redirect to("/media")
end

get '/search' do
   @media = Media.all(:title.like => "%#{params[:query]}%") | Media.all(:category.like => "%#{params[:query]}%")
   erb :search_html
end
get '/tags' do
    tags = Hash.new(0)
    Media.all(:order => [ :id.desc ]).each do |media|
       media.tags.split(',').each do |tag|
          tag = tag.strip
          tags[tag] += 1
       end
    end
    return tags.to_json
end
get '/media' do
    @data = []
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    @media.each do |f|
      hash = {} # convertir class a hash, y borrar metodos no necesarios
      f.instance_variables.each {|var| hash[var.to_s.delete("@")] = f.instance_variable_get(var) }
      hash.delete("_repository"); hash.delete("_key");hash.delete("_collection"); hash.delete("#"); hash.delete("_persistence_state")
      if f.name.match(/.mp3$/)
        hash[:mp3] = "audio/#{f.user_id}/#{f.name}"
      end
      if f.name.match(/.og(g|a)$/)
        hash[:oga] = "audio/#{f.user_id}/#{f.name}"
      end
      @data.push(hash)

    end
    @data.to_json
end

get '/users' do
    unless admin?
      redirect "/login"
    end
    @users = User.all(:order => [ :id.desc ], :limit => 20).to_json
end

get '/media/:md5' do
    @media = get_params(params[:md5]).to_json
end

get '/media/html' do # ¿porque no funciona?
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_html
end

get '/media/:md5/html' do
    @media = get_params(params[:md5])
    erb :media_html
end

get '/logout' do 
  session[:login] = nil
  redirect '/' 
end

get('/login'){ haml :admin }

get '/makeadmin' do #create default user
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(settings.password, password_salt)
    User.create(email: settings.login, pass: password_hash, salt: password_salt)
    redirect '/users' 
end

post '/login' do
  email=params['email']
  pass=params['password']
  user = User.first(:email=>email)
  salt = user.salt
  pass_hash = BCrypt::Engine.hash_secret(params[:password], salt)
  if User.all(:pass=>pass_hash, :email=>user.email)
     session[:login] = user.email
     redirect to("/")
  else
    'login failure'
    'Username or Password incorrect'
  end
end

get "/signup" do
  haml :signup
end

post "/signup" do
  email=params['login']
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  User.create(email: email, pass: password_hash, salt: password_salt)
  session[:login] = email
  flash[:login] = "Successfully created #{email}"
  redirect '/login'
end

def get_tags(file)
  data = {}
  TagLib::FileRef.open(file) do |file|
    prop = file.audio_properties
    tag = file.tag
    data = {:duration => prop.length, :bitrate => prop.bitrate, :channels => prop.channels}
    unless tag.artist.nil?
        data[:artist] = tag.artist
    end
    unless tag.title.nil?
        data[:title] = tag.title
    end
    unless tag.genre.nil?
        data[:genre] = tag.genre
    end
  end
  return data
end

get '/icestat' do
  @url = "http://localhost.org:8000"
  @res = ''
  open(@url, "User-Agent" => "Ruby/#{RUBY_VERSION}",
    "From" => "contacto@flujos.org",
    "Referer" => "http://www.flujos.org/") { |f|
    @res = f.read
  }
  doc = Hpricot(@res)
  #@streamdata.to_json
  #@streamdata.each do |mount|
  @mounts = []
  h = Hash.new
  (doc/"/html/body/div").each do |data|
     doc_x = Hpricot(data.inner_html)
     mount = doc_x.search("h3").inner_html.match(/\/.*$/)
     title = doc_x.search("//td[@class='streamdata']")[0]
     desc = doc_x.search("//td[@class='streamdata']")[1]
     type = doc_x.search("//td[@class='streamdata']")[2]
     created_at = doc_x.search("//td[@class='streamdata']")[3]
     current = doc_x.search("//td[@class='streamdata']")[-1]
     #regex = /Genre\:\s*(.*$)/
     #genre = doc_x.search("//td").inner_html.to_s.match(regex)
     h = {'mount' => mount, 'title' => title, 'description' => desc, 'type' => type, 'created_at' => created_at, 'current' => current } 
     @mounts.push(h)
  end
     #h = { 'title'=> mount[0], 'description' => mount[1], 'type' => mount[2], 'created_at' => mount[3], 'bitrate' => mount[4], 'listeners' => mount[5], 'peak' => mount[6], 'genre' => mount[7], 'url' => mount[8], 'song' => mount[9] }
     #@mounts << (doc_x/"table").inner_html
  return @mounts[1..-2].to_json
end
