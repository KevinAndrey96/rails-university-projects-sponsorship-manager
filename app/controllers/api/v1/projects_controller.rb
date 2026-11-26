module Api
  module V1
    class ProjectsController < BaseController
      def index
        projects = Project.with_funding.includes(:tutor).ordered
        projects = projects.where(status: params[:status]) if Project.statuses.key?(params[:status])
        page = Page.new(projects, number: params[:page], size: params.fetch(:per_page, Page::DEFAULT_SIZE))

        render json: {
          data: page.records.map { |project| serialize(project) },
          meta: { page: page.number, per_page: page.size, total_count: page.total_count, total_pages: page.total_pages }
        }
      end

      def show
        project = Project.includes(:tutor, :student_lead, sponsorships: :sponsor).find(params.expect(:id))

        render json: {
          data: serialize(project).merge(
            student_lead: project.student_lead&.slice(:name, :program, :semester),
            sponsorships: project.sponsorships.map do |sponsorship|
              { sponsor: sponsorship.sponsor.name, kind: sponsorship.sponsor.kind, amount: sponsorship.amount, committed_on: sponsorship.committed_on }
            end
          )
        }
      end

      private
        def serialize(project)
          {
            id: project.id,
            title: project.title,
            summary: project.summary,
            status: project.status,
            budget: project.budget,
            funded_amount: project.funded_amount,
            funding_ratio: project.funding_ratio.round(4),
            starts_on: project.starts_on,
            tutor: project.tutor&.slice(:name, :faculty)
          }
        end
    end
  end
end
