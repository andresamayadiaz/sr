class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_attached_file :logo, :styles => { :medium => "100x100>", :thumb => "50x50>" }, 
  :default_url => ActionController::Base.helpers.asset_path('avatar_default.jpg'),
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"
  
  validates_attachment :logo, :content_type => { :content_type => ["image/jpeg", "image/gif", "image/png"] },
    :size => { :in => 0..800.kilobytes }
  
  has_one :perfil
  
  after_create :build_perfil
  
  def build_perfil
    
    Perfil.create(user: self, notificarfaltas: true, notificaradvertencias: true, notificarvalidos: true)
  end
  
end
