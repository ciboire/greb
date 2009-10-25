# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_greb_session',
  :secret      => '61c427f2b70fca3816bef60f584b71c363e42b99b18a04b9abaf437dc456c6c4d41086bf65d942b5e8352ad6904ae2ea9f85f44e7b7a224977571ebbed76295c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
