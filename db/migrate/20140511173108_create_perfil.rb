class CreatePerfil < ActiveRecord::Migration
  def change
    create_table :perfils do |t|
      t.references :user
      t.string :calle
      t.string :noexterior
      t.string :nointerior
      t.string :colonia
      t.string :ciudad
      t.string :estado
      t.boolean :notificarfaltas
      t.boolean :notificaradvertencias
      t.boolean :notificarvalidos
      t.string :emailadicional1
      t.string :emailadicional2
    end
  end
end
