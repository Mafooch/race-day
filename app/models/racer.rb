class Racer

  # returns MongoDB client configured to communicate the default db
  # specified in the config/mongoid.yml file
  def self.mongo_client
    Mongoid::Clients.default
  end

  # returns the racers MongoDB collection holding the Racer documents
  def self.collection
    self.mongo_client["racers"]
  end

end
