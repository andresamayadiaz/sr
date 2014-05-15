class CreateReceptors < ActiveRecord::Migration
  def change
    create_table :receptors do |t|
      t.string :rfc
      t.text :nombre
      t.string :domicilio_calle
      t.string :domicilio_noExterior
      t.string :domicilio_noInterior
      t.string :domicilio_colonia
      t.string :domicilio_localidad
      t.string :domicilio_referencia
      t.string :domicilio_municipio
      t.string :domicilio_estado
      t.string :domicilio_pais
      t.string :domicilio_codigoPostal, limit: 5

      t.timestamps
    end
  end
end
