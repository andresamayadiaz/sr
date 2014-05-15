class Receptor < ActiveRecord::Base
  
  has_one :comprobante

=begin  
  validates :rfc, presence: true
=end
    
end