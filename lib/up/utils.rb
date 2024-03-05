require "money"

module Up
  module Utils
    class << self
      def format_currency(value, currency)
        value = value.to_f

        string = Money.from_amount(value.abs, currency).format

        if value > 0
          Rainbow("+ #{string}").green
        elsif value < 0
          Rainbow("- #{string}").red
        else
          Rainbow("  #{string}").white
        end
      end
    end
  end
end