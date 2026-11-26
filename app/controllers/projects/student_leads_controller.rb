module Projects
  class StudentLeadsController < ApplicationController
    before_action :set_project

    def new
      @student_lead = @project.build_student_lead
    end

    def create
      @student_lead = @project.build_student_lead(student_lead_params)

      if @student_lead.save
        redirect_to @project, notice: t(".created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @student_lead = @project.student_lead || raise(ActiveRecord::RecordNotFound)
    end

    def update
      @student_lead = @project.student_lead || raise(ActiveRecord::RecordNotFound)

      if @student_lead.update(student_lead_params)
        redirect_to @project, notice: t(".updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private
      def set_project
        @project = Project.find(params.expect(:project_id))
      end

      def student_lead_params
        params.expect(student_lead: %i[name program semester email])
      end
  end
end
