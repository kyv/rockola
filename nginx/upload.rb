# upload.rb
#
#Rockola API
#http://rockola.flujos.org
#
#Copyright 2012, kev 
#Licensed under the GPL Version 2 license.
#
#Descripción: interaccion con media (audio)

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
require 'librmpd'
require 'digest/md5'
enable :sessions

#set :dump_errors, false
set :html_path, '/srv/http/rockola/files' #hard links to /srv/media
set :store_path, '/srv/media' #git-media store media files
set :nginx_tmp, '/tmp'
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
    not @login.nil? # or if session[:login] not in db
  end
  def getuser; return @login; end
  def protected! ; halt [ 401, 'Not Authorized' ] unless admin? ; end
  def get_params(md5) ; return Media.all(:md5 => md5); end
end
before do
  @login = session[:login].inspect
  user = User.first(:email=>session[:login])
  @id = user.id
end
post '/update' do
   p params
   unless admin?
      redirect "/login"
   end
   title = params[:title]
   artist= params[:artist]
   genre = params[:genre]
   tags = params[:tags]
   id = params[:id]
   media = Media.first(id)
   media.update( title: title, artist: artist, genre: genre, tags: tags)
end
post '/upload' do
   data = Hash.new
   if defined? params['archivo.md5']
     data[:md5] = params['archivo.md5']
     data[:name] = params['archivo.name']
     data[:type] = params['archivo.content_type']
     data[:path] = params['archivo.path']
     data[:size] = params['archivo.size']
   end   
  # if defined? params['md5']
  #   md5 = params['md5']
  #   name = params['name']
  #   type = params['content_type']
  #   path = params['path']
  #   size = params['size']
  # end

   unless admin?
      h = Hash.new
      h[:type] = 'error'
      return h.to_json
   end
   user = User.first(:email=>session[:login])
   p user
   id = user.id

   store = settings.store_path + "/" + data[:md5]
   finpath = settings.html_path + "/" + user.id.to_s + "/" + data[:name]

  unless File.exists? settings.store_path
      FileUtils.mkdir_p settings.store_path
   end 
   unless File.exists? "#{settings.html_path}/#{user.id.to_s}" 
      FileUtils.mkdir_p "#{settings.html_path}/#{user.id.to_s}"
   end 

   if File.exists? store 
     flash[:upload] = 'File Exists'
   else
     FileUtils.cp(data[:path], store)
     FileUtils.ln(store, finpath)
     flash[:upload] = 'New file: ' + data[:name]
   end

   media_data = get_tags(finpath)
   if media_data[:genre].nil?
	genre = 'nil'
   else
        genre = media_data[:genre][0..50]
   end
   if media_data[:artist].nil?
	media_data[:artist] = 'nil'
   end
   if media_data[:title].nil?
	media_data[:title] = 'nil'
   end
   data[:title] = media_data[:title] 
   data[:artist] = media_data[:artist] 
   data[:genre] = media_data[:genre] 
   data[:duration] = media_data[:duration] 
   data[:channels] = media_data[:channels] 
   data[:bitrate] = media_data[:bitrate] 
   data[:tags] = "#{media_data[:artist]}, #{genre}"
   data[:user_id] = user.id
   @media = Array.new
   @media.push(Media.create(data))
   p @media.to_json
   return @media.to_json
end

get '/session' do
   unless @login.nil?
      return 'user' 
   else
      return nil
   end 
end

get '/search' do
   p params
   if params[:artist].nil?
      params[:artist] = 'xxx'
   end
   if params[:title].nil?
      params[:title] = 'xxx'
   end
   @media = Media.all(:title.like => "%#{params[:title]}%") | Media.all(:artist.like => "%#{params[:artist]}%")
   @media.to_json
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
get '/current' do
    mpd = MPD.new 'localhost', 6600
    mpd.connect
    c = mpd.current_song
    mpd.disconnect
    mpd = nil
    file = c.file.force_encoding('UTF-8')
    path = settings.html_path+ file
    name = File.basename(file)
    return get_media('16_-_Process_-_John_Lee_Hooker.mp3').to_json
end
get '/cola' do
    list = []
    mpd = MPD.new 'localhost', 6600
    mpd.connect
    playlist = mpd.playlist
    mpd.disconnect
    playlist.each do |song|
        h = Hash.new
        file = song.file.force_encoding('UTF-8')
	path = settings.html_path+ '/'+ file
        name = File.basename(file)
        get_media(name).each do |song|
	    list.push(song)
        end
    end
    list.to_json
end
def get_media(song_name)
    list = []
    mpd = MPD.new 'localhost', 6600
    mpd.connect
    current = mpd.current_song
    mpd.disconnect
    Media.all(:name.like => song_name).each do |song|
        p song.name
        h = Hash.new
        unless song.title.nil?
	    h[:title] = song.title.force_encoding('UTF-8')
        end
        unless song.artist.nil?
	    h[:artist] = song.artist.force_encoding('UTF-8')
        end
        unless song.genre.nil?
	    h[:genre] = song.genre.force_encoding('UTF-8')
        end
        if song.respond_to?('time')
	    h[:duration] = song.time
	end
        h[:file] = song.name.force_encoding('UTF-8')
        if song.name.match(/.mp3$/)
           h[:mp3] = "audio/#{song.user_id}/#{song.name}"
        end
        if song.name.match(/.og(g|a)$/)
           h[:oga] = "audio/#{song.user.id}/#{song.name}"
       end
        if song.id == current.id 
 	    h[:current] = true
        end
        list.push(h)
    end
    p list
    return list
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
  @login = nil
  if session[:login].nil? && @login.nil?
     return 'Vuelvas pronto'
  else
     return 'oops fallas al salir'
  end
end

get '/makeadmin' do #create default user
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(settings.password, password_salt)
    User.create(email: settings.login, pass: password_hash, salt: password_salt)
    redirect '/users' 
end

get('/login'){ 
   form = {:form => 'login', :md5 => params['md5'], :name => params['name'], :type => params['type'], :path => params['path'], :size => params['size'] }
   return form.to_json
}
post '/login' do
  unless open_captcha_valid?
     return 'Captcha invalido, intenta nuevamente' 
  end
  email=params['email']
  pass=params['password']
  user = User.first(:email=>email)
  if user.nil?
     return 'No existe tal usuario, intenta nuevamente'
  end
  salt = user.salt
  pass_hash = BCrypt::Engine.hash_secret(params[:password], salt)
  if User.all(:pass=>pass_hash, :email=>user.email)
     session[:login] = user.email
     p session[:login].inspect
     return 'Benvenidos '+ user.email 
  else
    return 'error:contrasena'
  end
end

get "/signup" do
    return '[{form:signup}]'
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
  @url = "http://radio.flujos.org:8000"
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
