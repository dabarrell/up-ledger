require "dry/cli"

require_relative "../client"

module Up
  module CLI
    class Balance < Dry::CLI::Command
      desc "Lists the accounts with balance as of a given timestamp"
      # TODO: this doesn't work. something to do with required flag
      # argument :account_id, required: false, type: :string, desc: "Account ID"
      option :timestamp, type: :string, desc: "Balance as of timestamp"

      def initialize
        @client = Up::Client.new
      end

      attr_reader :client

      def call(account_id: nil, timestamp: nil)
        timestamp = DateTime.parse(timestamp) if timestamp

        accounts = account_id ? [client.account(id: account_id)] : client.accounts
        transactions = client.transactions_since(account_id:, timestamp:)

        balances = accounts.to_h { |account| [account["id"], account["attributes"]["balance"]["value"].to_f] }

        transactions.each do |transaction|
          break if timestamp && DateTime.parse(transaction["attributes"]["createdAt"]) < timestamp

          account_id = transaction["relationships"]["account"]["data"]["id"]
          balances[account_id] -= transaction["attributes"]["amount"]["value"].to_f
        end

        table = Terminal::Table.new(headings: ["ID", "Type", "Name", "Balance", "Timestamp"])
        balances.each do |account_id, balance|
          account = accounts.find { |a| a["id"] == account_id }
          table << [
            account_id,
            account["attributes"]["accountType"],
            account["attributes"]["displayName"],
            Utils.format_currency(balance, "AUD"),
            timestamp
          ]
        end

        puts table
      end
    end
  end
end
