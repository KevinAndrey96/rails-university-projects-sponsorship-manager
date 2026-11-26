require "test_helper"

class CatalogControllersTest < ActionDispatch::IntegrationTest
  test "sponsors and tutors are public, filtered and hide contact data" do
    get sponsors_path(kind: "ngo")
    assert_select ".row", 1
    assert_select ".row-title", sponsors(:agua).name

    get sponsor_path(sponsors(:andina))
    assert_response :success
    assert_no_match sponsors(:andina).email, response.body

    get tutors_path
    assert_select ".row", 2

    get tutor_path(tutors(:diana))
    assert_select ".project-card", 1
    assert_no_match tutors(:diana).email, response.body
  end

  test "coordinators manage sponsors" do
    sign_in_as(users(:one))

    assert_difference "Sponsor.count", 1 do
      post sponsors_path, params: { sponsor: { name: "Nueva Empresa S.A.S.", kind: "company", nit: "811045673-2", phone: "300 123 4567", email: "c@nueva.example" } }
    end
    assert_redirected_to sponsor_path(Sponsor.find_by!(nit: "811045673-2"))

    post sponsors_path, params: { sponsor: { name: "Mala", kind: "company", nit: "811045673-9", phone: "123", email: "x@y.example" } }
    assert_response :unprocessable_content
    assert_select ".form-errors", /dígito de verificación/
  end

  test "sponsors with sponsorships cannot be deleted" do
    sign_in_as(users(:one))

    assert_no_difference "Sponsor.count" do
      delete sponsor_path(sponsors(:andina))
    end

    assert_redirected_to sponsor_path(sponsors(:andina))
    follow_redirect!
    assert_select ".flash-alert", /aportes registrados/
  end

  test "coordinators manage tutors" do
    sign_in_as(users(:one))

    post tutors_path, params: { tutor: { name: "Paula Díaz", faculty: "Facultad de Artes", email: "pdiaz@universidad.example" } }
    tutor = Tutor.find_by!(email: "pdiaz@universidad.example")
    assert_redirected_to tutor_path(tutor)

    patch tutor_path(tutor), params: { tutor: { faculty: "Facultad de Diseño" } }
    assert_equal "Facultad de Diseño", tutor.reload.faculty

    delete tutor_path(tutors(:diana))
    assert_nil projects(:landslides).reload.tutor_id
  end
end
