require "dry/cli"

require_relative "../client"

module Up
  module CLI
    class Accounts < Dry::CLI::Command
      desc "Lists the accounts"
      option :type, values: %w[saver transactional], required: false, desc: "Account types"
      option :search, type: :string, required: false, desc: "Filters accounts by name"

      def initialize
        @client = Up::Client.new
      end

      attr_reader :client

      def call(type: nil, search: nil)
        results = client.accounts(type:)

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
