# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mock_app_session',
  :secret      => '4211cebf6f8890d6f058b632c6f31efd04cff62520622a3949630345c11cd37d5b0ee83ad0e21d52898cd0a3f0758205b374ddfd1f1a9a397024d81555e39511'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
