# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_methlab_session',
  :secret      => '9b46130afe65ec2b265f17c14152259d28d4099b84f242354361fe5f7d9ae1ee912ceaa7dda875e7d3d1980b87149c666a42e907d11eb3ec15f70948d29b8ca0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
