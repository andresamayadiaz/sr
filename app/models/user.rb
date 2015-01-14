require "conekta"
Conekta.api_key = "key_NMzQNVDdYYzvDPrExSXFrA"

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :comprobantes, :dependent => :destroy
  
  has_attached_file :logo, :styles => { :medium => "100x100>", :thumb => "50x50>" }, 
  :default_url => ActionController::Base.helpers.asset_path('avatar_default.jpg'),
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"
  
  validates_attachment :logo, :content_type => { :content_type => ["image/jpeg", "image/gif", "image/png"] },
    :size => { :in => 0..800.kilobytes }
  
  validates :rfc, presence: true
  
  has_one :perfil
  has_many :notifications
  belongs_to :plan
  
  after_create :build_perfil
  after_create :process_conekta
  
  acts_as_tagger
  
  def build_perfil
    Perfil.create(user: self, notificarfaltas: true, notificaradvertencias: true, notificarvalidos: true)
  end
  
  def change_conekta_plan(new_plan_id)
      if self.update_attribute(:plan_id,new_plan_id)
        customer = Conekta::Customer.find(self.customer_id)
        subscription = customer.subscription.update({
          plan_id: new_plan_id
        })
      end
  end

  def process_conekta
    if self.plan.price.to_i > 0
      customer = Conekta::Customer.create({
        name: self.name,
        email: self.unconfirmed_email,
        phone: "55-5555-5555",
        cards: [self.conektaTokenId]
      })
      plan = Conekta::Plan.find(self.plan.id)
      subscription = customer.create_subscription({
        plan_id: plan.id
      })
      self.update_attribute(:subscription_status,subscription.status)
      self.update_attribute(:customer_id,customer.id)
    end
  end
  
  def tag_cloud
    tag_cloud = Array.new
    self.comprobantes.limit(50).each do |comprobante|
      comprobante.tag_list.each do |tag|
        return tag_cloud if tag_cloud.size >= 10
        tag_cloud.push(tag)
      end
    end
    return tag_cloud
  end 
  
end
