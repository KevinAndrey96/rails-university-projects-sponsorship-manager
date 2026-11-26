module Api
  module V1
    # Read-only public API. Responses are JSON and rate limited per client IP.
    class BaseController < ActionController::API
      rate_limit to: 120, within: 1.minute,
        with: -> { render json: { error: "rate_limited" }, status: :too_many_requests }

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "not_found" }, status: :not_found
      end
    end
  end
end
