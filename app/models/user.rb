require "conekta"
Conekta.api_key = "key_NMzQNVDdYYzvDPrExSXFrA"

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :comprobantes, :dependent => :destroy
  
  has_attached_file :logo, :styles => { :medium => "100x100>", :thumb => "50x50>" }, 
  :default_url => 'avatar_default.jpg'
  # ActionController::Base.helpers.asset_path(
  #:path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"
  
  validates_attachment :logo, :content_type => { :content_type => ["image/jpeg", "image/gif", "image/png"] },
    :size => { :in => 0..800.kilobytes }
  
  validates :rfc, presence: true
  
  validates_acceptance_of :terms, :allow_nil => false, :accept => true, :on => :create
  
  has_one :perfil
  has_many :notifications
  belongs_to :plan
  
  after_create :build_perfil
  after_create :process_conekta
  
  acts_as_tagger
  
  def build_perfil
    Perfil.create(user: self, notificarfaltas: true, notificaradvertencias: true, notificarvalidos: true)
  end
  
  def change_conekta_plan(params)
    plan = Conekta::Plan.find(params[:plan_id])
    if self.customer_id.blank? #create new Conekta objects
      customer = Conekta::Customer.create({
        name: self.name,
        email: self.email,
        phone: "00-0000-0000",
        cards: [params[:conektaTokenId]]
      })
      subscription = customer.create_subscription({
        plan_id: plan.id
      })
      self.update_attribute(:conektaTokenId,params[:conektaTokenId])
      self.update_attribute(:customer_id,customer.id)
    else #update plan on Conekta only
      customer = Conekta::Customer.find(self.customer_id)
      subscription = customer.subscription.update({
        plan_id: plan.id
      })
    end
    self.update_attribute(:plan_id,params[:plan_id])
    self.update_attribute(:subscription_status,subscription.status)
  end

  def process_conekta
    if self.plan.present? and self.plan.price.to_i > 0
      customer = Conekta::Customer.create({
        name: self.name,
        email: self.unconfirmed_email,
        phone: "00-0000-0000",
        cards: [self.conektaTokenId]
      })
      plan = Conekta::Plan.find(self.plan.id)
      subscription = customer.create_subscription({
        plan_id: plan.id
      })
      self.update_attribute(:subscription_status,subscription.status)
      self.update_attribute(:customer_id,customer.id)
    else
      plan = Plan.where(:price=>0).try(:first)
      self.update_attribute(:plan_id,plan.id)
    end
  end
  
  def tag_cloud
    
    tag_cloud = Array.new
    
    self.comprobantes.tag_counts_on(:tags).limit(10).each do |tag|
      
      tag_cloud.push(tag.name)
      
    end
    
    return tag_cloud
    
  end
  
end
