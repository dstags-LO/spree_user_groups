class Spree::Calculator::AdvancedFlatPercent < Spree::Calculator
  preference :flat_percent, :decimal, :default => 0
  preference :based_on_cost_price, :boolean, :default => false

  def self.description
    Spree.t(:advanced_flat_percent)
  end

  def description
    if self.preferred_based_on_cost_price
      "#{Spree.t(:cost_price)} + #{self.preferred_flat_percent}%"
    else
      "#{Spree.t(:price)} - #{self.preferred_flat_percent}%"
    end
  end

  def compute(object)
    return unless object.present? and object.line_items.present? and object.user.present?

    part = self.preferred_flat_percent.abs / 100.0
    item_total = object.line_items.map(&:amount).sum
    
    if self.preferred_based_on_cost_price
      item_cost_price_total = object.line_items.map do |li|
        if !li.variant.cost_price.nil? && li.variant.cost_price > 0
          li.variant.cost_price * li.quantity
        else
          li.amount
        end
      end.sum
      (item_cost_price_total * (1 + part) - item_total).round(2)
    else
      (item_total * (-part)).round(2)
    end
  end
  
  def compute_item(variant, price = nil)
    part = self.preferred_flat_percent.abs / 100.0
    original_price = price || Spree::Price.where(variant_id: variant.id).first

    if self.preferred_based_on_cost_price
      if !variant.cost_price.nil? && variant.cost_price > 0
        variant.cost_price * (1 + part)
      else
        original_price.amount
      end
    else
      original_price.amount * (1 - part)
    end
  end
end
