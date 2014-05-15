class Emisor < ActiveRecord::Base

  has_one :comprobante

=begin
  validates :rfc, presence: true
  validates :regimenFiscal, presence: true
=end

end