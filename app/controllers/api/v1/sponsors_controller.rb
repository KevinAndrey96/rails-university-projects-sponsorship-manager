module Api
  module V1
    class SponsorsController < BaseController
      def index
        totals = Sponsorship.group(:sponsor_id).sum(:amount)

        render json: {
          data: Sponsor.ordered.map do |sponsor|
            { id: sponsor.id, name: sponsor.name, kind: sponsor.kind, nit: sponsor.nit, committed_amount: totals.fetch(sponsor.id, 0) }
          end
        }
      end
    end
  end
end
