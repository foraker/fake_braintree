require "active_support/core_ext/hash/conversions"

module FakeBraintree
  class Transaction
    def initialize(data, id)
      @data = data
      @id = id
    end

    def create
      response = {
        "id" => id,
        "amount" => data["amount"],
        "status" => status,
        "type" => "sale",
        "credit_card" => credit_card.to_h
      }

      FakeBraintree.registry.transactions[id] = response
      response
    end

    private

    def status
      if submit_for_settlement?
        "submitted_for_settlement"
      else
        "authorized"
      end
    end

    def credit_card
      CreditCard.new(data['credit_card'] || {})
    end

    def submit_for_settlement?
      options.fetch("submit_for_settlement", false) == true
    end

    def options
      data.fetch("options", {})
    end

    attr_reader :data, :id
  end
end
