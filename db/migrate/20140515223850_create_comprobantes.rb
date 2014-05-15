class CreateComprobantes < ActiveRecord::Migration
  def change
    create_table :comprobantes do |t|
      t.string :version
      t.datetime :fecha
      t.text :sello
      t.string :formaDePago
      t.string :noCertificado
      t.text :certificado
      t.decimal :subTotal, precision: 10, scale: 6
      t.decimal :total, precision: 10, scale: 6
      t.string :tipoDeComprobante
      t.string :metodoDePago
      t.text :lugarExpedicion
      t.references :emisor, index: true
      t.references :receptor, index: true

      t.timestamps
    end
  end
end
