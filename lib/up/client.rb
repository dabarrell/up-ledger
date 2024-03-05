require "faraday"

module Up
  class Client
    def initialize(debug: false)
      @token = ENV["UP_API_TOKEN"]
      @conn = Faraday.new(
        url: "https://api.up.com.au"
      ) do |builder|
        builder.request :authorization, "Bearer", -> { ENV["UP_API_TOKEN"] }
        builder.request :json
        builder.response :json
        builder.response :raise_error
        builder.response :logger if debug
      end
    end

    def account(id:)
      get("/api/v1/accounts/#{id}", paginated: false)
    end

    def accounts(type: nil)
      params = {}

      if type == "saver"
        params["filter[accountType]"] = "SAVER"
      elsif type == "transactional"
        params["filter[accountType]"] = "TRANSACTIONAL"
      end

      get("/api/v1/accounts", params:, paginated: true)
    end

    def transactions(account_id:, pages: nil, filter: nil)
      get("/api/v1/accounts/#{account_id}/transactions", paginated: true, halt: (pages || filter) && ->(_, depth) {
        depth >= pages
      })
    end

    def transactions_after(timestamp:, account_id: nil)
      url = account_id ? "/api/v1/accounts/#{account_id}/transactions" : "/api/v1/transactions"

      get(url, paginated: true, halt: ->(data, _) {
        data.any? { |transaction| DateTime.parse(transaction["attributes"]["createdAt"]) < timestamp }
      })
    end

    private

    def get(url, params: {}, headers: {}, paginated: false, halt: nil, depth: 1)
      response = @conn.get(url, params, headers)

      raise "Request failed" unless response.success?

      body = response.body
      data = body["data"]

      if paginated && (next_url = body["links"]["next"]) && !halt&.call(data, depth)
        next_chunk = get(next_url, params:, headers:, paginated: true, halt:, depth: depth + 1)

        data = data.concat(next_chunk)
      end

      data
    end
  end
end
