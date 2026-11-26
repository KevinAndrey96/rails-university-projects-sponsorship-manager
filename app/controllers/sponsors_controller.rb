class SponsorsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_sponsor, only: %i[show edit update destroy]

  def index
    sponsors = Sponsor.ordered
    sponsors = sponsors.where(kind: params[:kind]) if Sponsor.kinds.key?(params[:kind])
    @page = Page.new(sponsors, number: params[:page])
  end

  def show
    @sponsorships = @sponsor.sponsorships.includes(:project).recent
  end

  def new
    @sponsor = Sponsor.new(kind: :company)
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)

    if @sponsor.save
      redirect_to @sponsor, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @sponsor.update(sponsor_params)
      redirect_to @sponsor, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @sponsor.destroy
      redirect_to sponsors_path, notice: t(".destroyed"), status: :see_other
    else
      redirect_to @sponsor, alert: t(".has_sponsorships"), status: :see_other
    end
  end

  private
    def set_sponsor
      @sponsor = Sponsor.find(params.expect(:id))
    end

    def sponsor_params
      params.expect(sponsor: %i[name kind nit phone email])
    end
end
