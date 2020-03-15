# frozen_string_literal: true

class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :status
      t.integer :total_score

      t.timestamps
    end

    create_table :frames do |t|
      t.string :status
      t.integer :number
      t.integer :total_score

      t.timestamps
    end

    create_table :throws do |t|
      t.integer :score
      t.integer :number

      t.timestamps
    end

    add_reference :frames, :game, foreign_key: true
    add_reference :throws, :frame, foreign_key: true
  end
end
