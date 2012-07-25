# upload.rb

# para arrancar
# gem install sinatra
# ruby -rubygems myapp.rb

require 'sinatra'

post '/upload' do
   "#{params}"
end
  
