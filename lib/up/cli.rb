require "dry/cli"
require_relative "cli/transactions"
require_relative "cli/accounts"
require_relative "cli/balance"

module Up
  module CLI
    extend Dry::CLI::Registry

    register "transactions", Transactions
    register "accounts", Accounts
    register "balance", Balance
  end
end
