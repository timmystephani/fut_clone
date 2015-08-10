class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :to_email
      t.text :body
      t.datetime :send_at
      t.string :subject
      t.datetime :sent_at

      t.timestamps null: false
    end
  end
end
