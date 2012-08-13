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

enable :sessions
#set :dump_errors, false
set :html_path, '/tmp/http/rockola/files' #hard links to /srv/media
set :store_path, '/tmp/media' #git-media store media files

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
  property :path,         String, :required => true
  property :size,         String, :required => true
  property :created_at, DateTime
  belongs_to :user
end

DataMapper.finalize
Media.auto_upgrade!
User.auto_upgrade!

helpers do
  def admin?
    if session[:login].nil?
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
   Media.create(name: name, md5: md5, type: type, path: finpath, user_id: id, size: size)
   if File.exists? store 
     flash[:upload] = 'File Exists'
   else
     FileUtils.cp(path, store)
     FileUtils.ln(store, finpath)
     flash[:upload] = 'New file: ' + name
   end
   redirect to("/media/#{md5}")
end
get '/media' do
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_html
end
get '/users' do
    unless admin?
      redirect "/login"
    end
    @users = User.all(:order => [ :id.desc ], :limit => 20)
    erb :users_html
end
get '/media/:md5' do
    @media = get_params(params[:md5])
    erb :media_html
end
get '/media/json' do # ¿porque no funciona?
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_json, :layout => false
end
get '/media/:md5/json' do
    @media = get_params(params[:md5])
    erb :media_json, :layout => false
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
