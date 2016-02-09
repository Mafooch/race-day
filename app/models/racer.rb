class Racer
  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def initialize params = {}
    # hash is coming from web page (parmas[:id]) or MongoDB query. We must assign
    # the value to whatever is not nil. have to call to_s if it's from a query because
    # the object returned my a mongo _id is a BSON object
    @id = params[:_id].nil? ? params[:id] : params[:_id].to_s
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
  end

  def save
    result = Racer.collection.insert_one(_id: @id, number: @number, first_name: @first_name, last_name: @last_name, gender: @gender, group: @group, secs: @secs)
    @id = result.inserted_id.to_s
  end

  def update params
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i

    self.class.collection
              .find(_id: BSON::ObjectId.from_string(@id))
              .update_one(:$set => { number: params[:number], first_name: params[:first_name], last_name: params[:last_name], gender: params[:gender], group: params[:group], secs: params[:secs] })
  end

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

    result
  end

  def self.find id
    result = collection.find(:_id=>BSON::ObjectId.from_string(id)).first
    return result.nil? ? nil : Racer.new(result)
  end
end
