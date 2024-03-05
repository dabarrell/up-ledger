require "dry/cli"

require_relative "../client"

module Up
  module CLI
    class Balance < Dry::CLI::Command
      desc "Lists the accounts"
      argument :account_id, type: :string, required: false, desc: "Account ID"
      option :timestamp, type: :string, desc: "Balance as of timestamp"

      def initialize
        @client = Up::Client.new
      end

      attr_reader :client

      def call(account_id: nil, timestamp: nil)
        timestamp = DateTime.parse(timestamp) if timestamp

        account = client.account(id: account_id)
        transactions = client.transactions_after(account_id:, timestamp:)

        balance = account["attributes"]["balance"]["value"].to_f
        transactions.each do |transaction|
          break if timestamp && DateTime.parse(transaction["attributes"]["createdAt"]) < timestamp
          balance -= transaction["attributes"]["amount"]["value"].to_f
        end

        table = Terminal::Table.new(headings: ["ID", "Type", "Name", "Balance", "Timestamp"])
        table << [
          account["id"],
          account["attributes"]["accountType"],
          account["attributes"]["displayName"],
          Utils.format_currency(balance, "AUD"),
          timestamp
        ]

        puts table
      end
    end
  end
end
