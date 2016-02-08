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

  def self.all prototype = {}, sort = { number: 1 }, skip = 0, limit = nil
    tmp = {}
    sort.each do |k, v|
      k = k.to_sym
      tmp[k] = v if [:number, :first_name, :last_name, :gender, :group, :secs].include?(k)
    end
    sort = tmp

    #convert to keys and then eliminate any properties not of interest
    prototype = prototype.symbolize_keys.slice(:number, :first_name, :last_name, :gender, :group, :secs) unless prototype.nil?

    Rails.logger.debug { "getting all racers, prototype=#{prototype}, sort=#{sort}, skip=#{skip}, limit=#{limit}" }

    result = collection.find(prototype)
             .sort(sort)
             .skip(skip)
    result = result.limit limit unless limit.nil?

    return result
  end

end
