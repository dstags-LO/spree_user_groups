class AddMinimumOrderToGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :spree_user_groups, :minimum_order, :int, :default => 0
  end

  def down
    remove_column :spree_user_groups, :minimum_order
  end
end
