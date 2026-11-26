class ProjectsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_project, only: %i[show edit update destroy]
  before_action :load_tutors, only: %i[new create edit update]

  def index
    projects = Project.with_funding.includes(:tutor).ordered
    projects = projects.where(status: params[:status]) if Project.statuses.key?(params[:status])

    respond_to do |format|
      format.html do
        @summary = FundingSummary.new
        @page = Page.new(projects, number: params[:page], size: 12)
      end
      format.csv do
        send_data FundingReport.new(projects).to_csv, filename: "reporte-financiacion-#{Date.current.iso8601}.csv", type: "text/csv"
      end
    end
  end

  def show
    @sponsorships = @project.sponsorships.includes(:sponsor).recent
    @sponsorship = @project.sponsorships.build(committed_on: Date.current) if authenticated?
    @available_sponsors = Sponsor.ordered.where.not(id: @project.sponsor_ids).pluck(:name, :id) if authenticated?
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy!
    redirect_to projects_path, notice: t(".destroyed"), status: :see_other
  end

  private
    def set_project
      @project = Project.find(params.expect(:id))
    end

    def load_tutors
      @tutors = Tutor.order(:name).pluck(:name, :id)
    end

    def project_params
      params.expect(project: %i[title summary status budget starts_on tutor_id])
    end
end
