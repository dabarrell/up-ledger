require "dry/cli"

require_relative "../client"

module Up
  module CLI
    class Balance < Dry::CLI::Command
      desc "Lists the accounts"
      argument :account_id, type: :string, required: true, desc: "Account ID"
      option :timestamp, type: :string, desc: "Balance as of timestamp"

      def initialize
        @client = Up::Client.new
      end

      attr_reader :client

      def call(type: nil, search: nil)
        results = client.transactions(account_id:) # limit?

        table = Terminal::Table.new(headings: ["ID", "Type", "Name", "Balance", "Created At"])

        results.each do |account|
          next if search && !account["attributes"]["displayName"].include?(search)

          value = Utils.format_currency(account["attributes"]["balance"]["value"], account["attributes"]["balance"]["currencyCode"])

          table << [
            account["id"],
            account["attributes"]["accountType"],
            account["attributes"]["displayName"],
            value,
            account["attributes"]["createdAt"]
          ]
        end

        puts table
      end
    end
  end
end
