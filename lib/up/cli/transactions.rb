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
      option :pages, type: :number, desc: "pages the number of transactions"

      def initialize
        @client = Up::Client.new(debug: false)
      end

      attr_reader :client

      def call(account_id:, pages: nil)
        results = client.transactions(account_id:, pages: pages&.to_i)
        account = client.account(id: account_id)

        table = Terminal::Table.new(headings: ["ID", "Description", "Amount", "Balance", "Currency", "Status", "Timestamp"])

        balance = account["attributes"]["balance"]["value"].to_f
        results.each do |transaction|
          value = Utils.format_currency(transaction["attributes"]["amount"]["value"], transaction["attributes"]["amount"]["currencyCode"])
          balance_value = Utils.format_currency(balance, transaction["attributes"]["amount"]["currencyCode"])

          table << [
            transaction["id"],
            transaction["attributes"]["description"],
            value,
            balance_value,
            transaction["attributes"]["amount"]["currencyCode"],
            transaction["attributes"]["status"],
            transaction["attributes"]["createdAt"]
          ]

          balance -= transaction["attributes"]["amount"]["value"].to_f
        end

        puts table
      end
    end
  end
end
