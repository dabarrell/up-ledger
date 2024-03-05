#!/usr/bin/env ruby

require "bundler/setup"
require "dry/cli"
require "dotenv/load"
require "money"
require_relative "lib/up/cli"

Money.locale_backend = :currency
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

Dry::CLI.new(Up::CLI).call
