# frozen_string_literal: true

module CheckoutsHelper
  def product_name(code)
    I18n.t("checkout.products.#{code.downcase}")
  end

  def offer_label(rule)
    values = rule.params.transform_values { |value| value.is_a?(BigDecimal) ? number_to_currency(value) : value }
    I18n.t("checkout.rules.#{rule.name}", **values)
  end

  def checkout_with(code)
    checkout_path(items: [params[:items], code].compact_blank.join(','))
  end
end
