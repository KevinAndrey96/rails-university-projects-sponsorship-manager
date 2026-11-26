module Projects
  class SponsorshipsController < ApplicationController
    before_action :set_project

    def create
      @sponsorship = @project.sponsorships.build(sponsorship_params)

      if @sponsorship.save
        redirect_to @project, notice: t(".created")
      else
        @available_sponsors = Sponsor.ordered.where.not(id: @project.sponsor_ids).pluck(:name, :id)
        render turbo_stream: turbo_stream.replace("sponsorship_form", partial: "projects/sponsorships/form",
          locals: { project: @project, sponsorship: @sponsorship, sponsors: @available_sponsors }), status: :unprocessable_content
      end
    end

    def destroy
      @project.sponsorships.find(params.expect(:id)).destroy!
      redirect_to @project, notice: t(".destroyed"), status: :see_other
    end

    private
      def set_project
        @project = Project.find(params.expect(:project_id))
      end

      def sponsorship_params
        params.expect(sponsorship: %i[sponsor_id amount committed_on])
      end
  end
end
