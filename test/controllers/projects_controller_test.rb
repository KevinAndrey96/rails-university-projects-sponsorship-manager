require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "anyone can browse projects with funding progress and filter by status" do
    get projects_path

    assert_response :success
    assert_select "h1", "Proyectos"
    assert_select ".project-card", 3
    assert_select ".kpi", 4

    get projects_path(status: "proposed")
    assert_select ".project-card", 2
  end

  test "anyone can see a project, but contact data and edit controls need a session" do
    get project_path(projects(:landslides))

    assert_response :success
    assert_select "h1", projects(:landslides).title
    assert_select ".row", 2
    assert_no_match "vrios@estudiantes.example", response.body
    assert_select "#sponsorship_form", 0
  end

  test "exports the funding report as csv" do
    get projects_path(format: :csv)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match "porcentaje_financiado", response.body
  end

  test "writing requires a session" do
    post projects_path, params: { project: { title: "X" } }
    assert_redirected_to new_session_path

    delete project_path(projects(:gardens))
    assert_redirected_to new_session_path
  end

  test "coordinators create, update and delete projects" do
    sign_in_as(users(:one))

    assert_difference "Project.count", 1 do
      post projects_path, params: { project: { title: "Bioplásticos de yuca", summary: "Empaques compostables.", status: "proposed", budget: "35000000", tutor_id: tutors(:carlos).id } }
    end
    project = Project.find_by!(title: "Bioplásticos de yuca")
    assert_redirected_to project_path(project)

    patch project_path(project), params: { project: { status: "in_progress" } }
    assert project.reload.in_progress?

    assert_difference "Project.count", -1 do
      delete project_path(project)
    end
    assert_redirected_to projects_path
  end

  test "invalid projects re-render the form" do
    sign_in_as(users(:one))

    post projects_path, params: { project: { title: "", summary: "", status: "proposed", budget: "0" } }

    assert_response :unprocessable_content
    assert_select ".form-errors li", 3
  end
end
