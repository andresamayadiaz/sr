class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_one :perfil
  
  after_create :build_perfil
  
  def build_perfil
    
    Perfil.create(user: self, notificarfaltas: true, notificaradvertencias: true, notificarvalidos: true) # Associations must be defined correctly for this syntax, avoids using ID's directly.
  end
  
end
