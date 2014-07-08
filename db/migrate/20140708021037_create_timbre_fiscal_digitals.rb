class CreateTimbreFiscalDigitals < ActiveRecord::Migration
  def change
    create_table :timbre_fiscal_digitals do |t|
      t.string :version
      t.string :uuid
      t.datetime :fechaTimbrado
      t.text :selloCFD
      t.string :noCertificadoSAT
      t.text :selloSAT
      t.references :comprobante, index: true

      t.timestamps
    end
  end
end
