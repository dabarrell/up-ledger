require "dry/cli"
require "rainbow"
require "terminal-table"

require_relative "../client"
require_relative "../utils"

module Up
  module CLI
    class Transactions < Dry::CLI::Command
      desc "Lists the transactions for an account"
      argument :account_id, type: :string, required: true, desc: "Account ID"
      option :limit, type: :number, desc: "Limit the number of transactions"

      def initialize
        @client = Up::Client.new(debug: false)
      end

      attr_reader :client

      def call(account_id:, limit: nil)
        results = client.transactions(account_id:, limit: limit&.to_i)

        table = Terminal::Table.new(headings: ["ID", "Description", "Amount", "Currency", "Status", "Created At"])

        results.each do |transaction|
          value = Utils.format_currency(transaction["attributes"]["amount"]["value"], transaction["attributes"]["amount"]["currencyCode"])

          table << [
            transaction["id"],
            transaction["attributes"]["description"],
            value,
            transaction["attributes"]["amount"]["currencyCode"],
            transaction["attributes"]["status"],
            transaction["attributes"]["createdAt"]
          ]
        end

        puts table
      end
    end
  end
end
