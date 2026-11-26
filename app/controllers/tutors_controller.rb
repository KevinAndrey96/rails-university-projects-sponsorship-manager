class TutorsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_tutor, only: %i[show edit update destroy]

  def index
    @page = Page.new(Tutor.includes(:projects).order(:name), number: params[:page])
  end

  def show
    @projects = @tutor.projects.with_funding.ordered
  end

  def new
    @tutor = Tutor.new
  end

  def create
    @tutor = Tutor.new(tutor_params)

    if @tutor.save
      redirect_to @tutor, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @tutor.update(tutor_params)
      redirect_to @tutor, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @tutor.destroy!
    redirect_to tutors_path, notice: t(".destroyed"), status: :see_other
  end

  private
    def set_tutor
      @tutor = Tutor.find(params.expect(:id))
    end

    def tutor_params
      params.expect(tutor: %i[name faculty email])
    end
end
