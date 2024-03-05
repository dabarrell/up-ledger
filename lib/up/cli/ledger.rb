require "dry/cli"
require "rainbow"
require "terminal-table"

require_relative "../client"
require_relative "../utils"

module Up
  module CLI
    class Ledger < Dry::CLI::Command
      desc "Generates ledger entry for an account between two dates"
      argument :account_id, type: :string, required: true, desc: "Account ID"
      option :from, required: true, type: :string, desc: "From"
      option :to, required: true, type: :string, desc: "To"
      option :income, required: true, type: :integer, desc: "Income (manually calculated)"
      option :sweep, required: true, type: :integer, desc: "Sweep (manually calculated)"

      def initialize
        @client = Up::Client.new(debug: false)
      end

      attr_reader :client

      def call(account_id:, from:, to:, income:, sweep:)
        account = client.account(id: account_id)
        transactions = client.transactions(account_id:, from: DateTime.parse(from), to: DateTime.parse(to))

        print_ledger(transactions, account, from, to, income.to_f, sweep.to_f)

        print_transactions(transactions, account)
      end

      private

      def print_ledger(transactions, account, from, to, income, sweep)
        interest = 0
        withdrawals = 0 - income - sweep

        transactions.each do |transaction|
          value = transaction["attributes"]["amount"]["value"].to_f

          if transaction["attributes"]["description"] == "Interest"
            interest += value
          else
            withdrawals += value
          end
        end

        table = Terminal::Table.new(headings: ["ID", "Name", "Income", "Sweep", "Withdrawals", "Interest", "Balance", "From", "To"])

        table << [
          account["id"],
          account["attributes"]["displayName"],
          Utils.format_currency(income),
          Utils.format_currency(sweep),
          Utils.format_currency(withdrawals),
          Utils.format_currency(interest),
          "sdfsdf",
          from,
          to
        ]

        puts table
      end

      def print_transactions(transactions, account)
        table = Terminal::Table.new(headings: ["ID", "Description", "Amount", "Balance", "Currency", "Status", "Timestamp"])

        balance = account["attributes"]["balance"]["value"].to_f
        transactions.each do |transaction|
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
