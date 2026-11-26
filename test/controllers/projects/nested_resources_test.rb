require "test_helper"

module Projects
  class NestedResourcesTest < ActionDispatch::IntegrationTest
    setup { sign_in_as(users(:one)) }

    test "registers a sponsorship and only offers sponsors not backing the project yet" do
      get project_path(projects(:landslides))
      assert_select "#sponsorship_sponsor_id option", 2
      assert_select "#sponsorship_sponsor_id option", text: sponsors(:agua).name

      assert_difference "projects(:landslides).sponsorships.count", 1 do
        post project_sponsorships_path(projects(:landslides)), params: { sponsorship: { sponsor_id: sponsors(:agua).id, amount: "30000000", committed_on: "2026-06-01" } }
      end

      assert_redirected_to project_path(projects(:landslides))
      assert projects(:landslides).fully_funded?
    end

    test "an invalid sponsorship answers with a turbo stream that replaces the form" do
      post project_sponsorships_path(projects(:gardens)), params: { sponsorship: { sponsor_id: sponsors(:agua).id, amount: "0", committed_on: "2026-06-01" } },
        as: :turbo_stream

      assert_response :unprocessable_content
      assert_turbo_stream action: :replace, target: "sponsorship_form", status: :unprocessable_content do
        assert_select ".form-errors"
      end
    end

    test "withdraws a sponsorship" do
      assert_difference "Sponsorship.count", -1 do
        delete project_sponsorship_path(projects(:coffee), sponsorships(:coffee_andina))
      end

      assert_redirected_to project_path(projects(:coffee))
    end

    test "cannot withdraw a sponsorship through another project" do
      delete project_sponsorship_path(projects(:gardens), sponsorships(:coffee_andina))

      assert_response :not_found
    end

    test "assigns and updates the student lead" do
      post project_student_lead_path(projects(:gardens)), params: { student_lead: { name: "Ana Torres", program: "Agronomía", semester: "6", email: "atorres@estudiantes.example" } }
      assert_redirected_to project_path(projects(:gardens))
      assert_equal "Ana Torres", projects(:gardens).reload.student_lead.name

      patch project_student_lead_path(projects(:gardens)), params: { student_lead: { semester: "7" } }
      assert_equal 7, projects(:gardens).student_lead.reload.semester
    end

    test "editing a missing student lead is not found" do
      get edit_project_student_lead_path(projects(:gardens))

      assert_response :not_found
    end
  end
end
