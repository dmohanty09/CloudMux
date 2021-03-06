#
# Captures details about cloud account
#
class CloudAccount
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :cloud
  belongs_to :org
  embeds_many :cloud_services
  embeds_many :prices
  embeds_many :cloud_mappings, :as=>:mappable # CloudMapping
  has_and_belongs_to_many :config_managers

  field :name, type:String
  field :url, type:String
  field :default_region, type:String
  field :protocol, type:String
  field :host, type:String
  field :port, type:String
  field :topstack_enabled, type:Boolean, default:false
  field :topstack_id, type:String

  # Validation Rules
  validates_associated :org
  validates_associated :cloud

  def cloud_name
    (cloud.nil? ? nil : cloud.name)
  end
  def cloud_name=(name); end; # no-op: for the representer only
  
  def cloud_provider
    (cloud.nil? ? nil : cloud.cloud_provider)
  end
  def cloud_provider=(name); end # no-op: for the representer only  

  def public
    (cloud.nil? ? nil : cloud.public)
  end
  def public=(name); end # no-op: for the representer only  
  
  def find_price(price_id)
    prices.select { |e| e.id.to_s == price_id.to_s }.first
  end

  def find_service(service_id)
    cloud_services.select { |s| s.id.to_s == service_id.to_s }.first
  end

  def find_mapping(mapping_id)
    cloud_mappings.select { |m| m.id.to_s == mapping_id.to_s }.first
  end

  def remove_service!(service_id)
    cloud_services.select { |s| s.id.to_s == service_id.to_s }.each { |s| s.delete }
    self.save!
  end

  def remove_mapping!(mapping_id)
    cloud_mappings.select { |s| s.id.to_s == mapping_id.to_s }.each { |s| s.delete }
    self.save!
  end
  
  def remove_price!(price_id)
  prices.select{ |s| s.id.to_s == price_id.to_s }.each { |s| s.delete }
  end

  def self.query_authorized?(account_id)
    account = Account.find(account_id)
    !account.permissions.detect {|p| p["name"] == "admin"}.nil?
  end
end
