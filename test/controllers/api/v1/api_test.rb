require "test_helper"

module Api
  module V1
    class ApiTest < ActionDispatch::IntegrationTest
      test "lists projects with funding and pagination metadata" do
        get api_v1_projects_path(status: "in_progress")

        assert_response :success
        body = response.parsed_body
        assert_equal [ projects(:landslides).title ], body["data"].pluck("title")
        assert_equal 150_000_000, body["data"].first["funded_amount"]
        assert_equal 1, body.dig("meta", "total_count")
      end

      test "shows a project with its lead and sponsorships without contact data" do
        get api_v1_project_path(projects(:landslides))

        data = response.parsed_body["data"]
        assert_equal "Valentina Ríos", data.dig("student_lead", "name")
        assert_equal 2, data["sponsorships"].size
        assert_no_match "vrios@estudiantes.example", response.body
      end

      test "lists sponsors with their committed amount" do
        get api_v1_sponsors_path

        andina = response.parsed_body["data"].find { |sponsor| sponsor["nit"] == sponsors(:andina).nit }
        assert_equal 120_000_000, andina["committed_amount"]
        assert_no_match sponsors(:andina).phone, response.body
      end

      test "returns json not found" do
        get api_v1_project_path(id: 0)

        assert_response :not_found
        assert_equal "not_found", response.parsed_body["error"]
      end
    end
  end
end
