require "dry/cli"
require_relative "cli/transactions"
require_relative "cli/accounts"
require_relative "cli/balance"
require_relative "cli/ledger"

module Up
  module CLI
    extend Dry::CLI::Registry

    register "transactions", Transactions
    register "accounts", Accounts
    register "balance", Balance
    register "ledger", Ledger
  end
end
