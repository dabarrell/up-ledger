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

    def transactions(account_id: nil, pages: nil, from: nil, to: nil)
      url = account_id ? "/api/v1/accounts/#{account_id}/transactions" : "/api/v1/transactions"
      params = {}
      params["filter[since]"] = from.iso8601 if from
      params["filter[until]"] = to.iso8601 if to

      get(url, params:, paginated: true, pages:)
    end

    private

    def get(url, params: {}, headers: {}, paginated: false, pages: nil, depth: 1)
      response = @conn.get(url, params, headers)

      raise "Request failed" unless response.success?

      body = response.body
      data = body["data"]

      if paginated && (next_url = body["links"]["next"]) && (pages.nil? || depth < pages)
        next_chunk = get(next_url, params:, headers:, paginated: true, pages:, depth: depth + 1)

        data = data.concat(next_chunk)
      end

      data
    end
  end
end
