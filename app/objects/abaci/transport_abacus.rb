class TransportAbacus
  attr_reader :single_transports, :unified_transport, :free_transport

  def self.calculate business_transaction_abacus
    abacus = TransportAbacus.new(business_transaction_abacus)
    abacus.check_free_transport
    abacus.calculate_single_transports
    abacus.calculate_unified_transport if business_transaction_abacus.line_item_group.unified_transport
    abacus
  end

  def check_free_transport
    free_at_price = @line_item_group.free_transport_at_price_cents
    @free_transport = ( free_at_price &&  @business_transaction_abacus.total_retail_price >= free_at_price )
  end

  def calculate_single_transports
    result = @business_transaction_abacus.single_transports.map do |bt|
      single_transport_price, transport_number = bt.article.transport_details_for bt.selected_transport.to_sym
      shipments = self.class.number_of_shipments(bt.quantity_bought, transport_number)
      [bt,{
        method: bt.selected_transport.to_sym,
        provider: bt.single_transport_provider,
        shipments: shipments,
        price: self.class.transport_price(single_transport_price, shipments),
        cash_on_delivery:  (bt.selected_payment == :cash_on_delivery) ?  bt.article_cash_on_delivery_price : nil
      }]
    end
    @single_transports = result.to_h
  end

  def calculate_unified_transport
    number_of_items = @business_transaction_abacus.unified_transport.map(&:quantity_bought).sum
    shipments = self.class.number_of_shipments(number_of_items, @line_item_group.unified_transport_maximum_articles)
    @unified_transport = {
      business_transactions: @business_transaction_abacus.unified_transport,
      method: :unified,
      provider: @line_item_group.unified_transport_provider,
      shipments: shipments,
      price: self.class.transport_price(@line_item_group.unified_transport_price, shipments),
      cash_on_delivery: unified_with_cash_on_delivery? ? @line_item_group.unified_transport_cash_on_delivery_price : nil
    }
  end

  private
    def initialize business_transaction_abacus
      @line_item_group = business_transaction_abacus.line_item_group
      @business_transaction_abacus = business_transaction_abacus
    end

    def self.transport_price single_transport_price, number_of_shipments
      @free_transport ? Money.new(0) : (single_transport_price * number_of_shipments)
    end

    def self.number_of_shipments quantity, maximum_per_shipment
      return 0 if maximum_per_shipment == 0
      quantity.fdiv(maximum_per_shipment).ceil
    end

    def unified_with_cash_on_delivery?
      @business_transaction_abacus.unified_transport.select{ |bt| bt.selected_payment.cash_on_delivery? }.any?
    end
end
