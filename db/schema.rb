# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140602022905) do

  create_table "comprobantes", force: true do |t|
    t.string   "version"
    t.datetime "fecha"
    t.text     "sello"
    t.string   "formaDePago"
    t.string   "noCertificado"
    t.text     "certificado"
    t.decimal  "subTotal",          precision: 17, scale: 6, default: 0.0
    t.decimal  "total",             precision: 17, scale: 6, default: 0.0
    t.string   "tipoDeComprobante"
    t.string   "metodoDePago"
    t.text     "lugarExpedicion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xml_file_name"
    t.string   "xml_content_type"
    t.integer  "xml_file_size"
    t.datetime "xml_updated_at"
    t.boolean  "emitido",                                    default: false
    t.boolean  "recibido",                                   default: false
    t.integer  "user_id"
  end

  add_index "comprobantes", ["emitido"], name: "index_comprobantes_on_emitido", using: :btree
  add_index "comprobantes", ["recibido"], name: "index_comprobantes_on_recibido", using: :btree
  add_index "comprobantes", ["user_id"], name: "index_comprobantes_on_user_id", using: :btree

  create_table "emisors", force: true do |t|
    t.string   "rfc"
    t.text     "regimenFiscal"
    t.text     "nombre"
    t.string   "domicilio_calle"
    t.string   "domicilio_noExterior"
    t.string   "domicilio_noInterior"
    t.string   "domicilio_colonia"
    t.string   "domicilio_localidad"
    t.string   "domicilio_referencia"
    t.string   "domicilio_municipio"
    t.string   "domicilio_estado"
    t.string   "domicilio_pais"
    t.string   "domicilio_codigoPostal", limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comprobante_id"
  end

  add_index "emisors", ["comprobante_id"], name: "index_emisors_on_comprobante_id", using: :btree

  create_table "perfils", force: true do |t|
    t.integer "user_id"
    t.string  "calle"
    t.string  "noexterior"
    t.string  "nointerior"
    t.string  "colonia"
    t.string  "ciudad"
    t.string  "estado"
    t.boolean "notificarfaltas"
    t.boolean "notificaradvertencias"
    t.boolean "notificarvalidos"
    t.string  "emailadicional1"
    t.string  "emailadicional2"
    t.string  "cp"
  end

  create_table "receptors", force: true do |t|
    t.string   "rfc"
    t.text     "nombre"
    t.string   "domicilio_calle"
    t.string   "domicilio_noExterior"
    t.string   "domicilio_noInterior"
    t.string   "domicilio_colonia"
    t.string   "domicilio_localidad"
    t.string   "domicilio_referencia"
    t.string   "domicilio_municipio"
    t.string   "domicilio_estado"
    t.string   "domicilio_pais"
    t.string   "domicilio_codigoPostal", limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comprobante_id"
  end

  add_index "receptors", ["comprobante_id"], name: "index_receptors_on_comprobante_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "rfc"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["rfc"], name: "index_users_on_rfc", unique: true, using: :btree

end
