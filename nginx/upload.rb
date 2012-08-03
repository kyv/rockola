# upload.rb

# para arrancar
# gem install sinatra
# ruby -rubygems upload.rb

require 'sinatra'
require 'fileutils'
require 'data_mapper'
require 'sinatra/flash'


enable :sessions
set :username,'Bond'
set :token,'shakenN0tstirr3d'
set :password,'007'
set :session_secret, "A1 sauce 1s so good you should use 1t on a11 yr st34ksssss"
#set :dump_errors, false
set :html_path, '/tmp/http/rockola/files' #hard links to /srv/media
#html_path = '/srv/http/rockola/files/$user' caundo tenemos sessiones
set :store_path, '/tmp/media' #git-media store media files

# inicializar base de datos
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

helpers do
  def admin? ; request.cookies[settings.username] == settings.token ; end
  def protected! ; halt [ 401, 'Not Authorized' ] unless admin? ; end
  def get_params(md5) ; return Media.all(:md5 => md5); end
end

post '/upload' do

   unless admin?
      set :params,  params
      redirect "/login"
   end
   if defined? params['file.md5']
     md5 = params['file.md5']
     name = params['file.name']
     type = params['file.content_type']
     path = params['file.path']
     size = params['file.size']
     submit = params['submit']
   end

   store = settings.store_path + "/" + md5
   if File.exists? store 
     flash[:upload] = 'File Exists'
     redirect to("/media/#{md5}")
   end
   user = request.cookies[settings.username]
   finpath = settings.html_path + "/" + name
   FileUtils.cp(path, store)
   FileUtils.ln(store, finpath)
   #Media.create(params)
   Media.create(name: name, md5: md5, type: type, path: finpath, size: size, user: user)
   flash[:upload] = 'New file: ' + name
   redirect to("/media/#{md5}")

   response.set_cookie(settings.params, false)
   redirect to("/media/#{md5}")
end
get '/media' do
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_html
end
get '/media/:md5' do
    @media = get_params(params[:md5])
    erb :media_html
end
get '/media/json' do # ¿porque no funciona?
    @media = Media.all(:order => [ :id.desc ], :limit => 20)
    erb :media_json, :layout => false
end
get '/media/:md5/:json' do
    @media = get_params(params[:md5])
    erb :media_json, :layout => false
end

get '/logout' do 
  response.set_cookie(settings.username, false)
  redirect '/' 
end
get('/login'){ haml :admin }
post '/login' do
  if params['username']==settings.username&&params['password']==settings.password
    response.set_cookie(settings.username,settings.token) 
    redirect to("/")
  else
    "Username or Password incorrect"
  end

  #response.set_cookie("origin", :value => "/upload", :domain => "")
end
