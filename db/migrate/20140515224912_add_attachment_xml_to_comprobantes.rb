class AddAttachmentXmlToComprobantes < ActiveRecord::Migration
  def self.up
    change_table :comprobantes do |t|
      t.attachment :xml
    end
  end

  def self.down
    drop_attached_file :comprobantes, :xml
  end
end
