require "dry/cli"
require_relative "cli/transactions"
require_relative "cli/accounts"

module Up
  module CLI
    extend Dry::CLI::Registry

    register "transactions", Transactions
    register "accounts", Accounts
  end
end
