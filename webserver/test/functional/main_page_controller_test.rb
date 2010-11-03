require 'test_helper'

class MainPageControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "get" do
    get :serve
    assert_response :success
  end

  test "serving page generates a session id" do
    get :serve
    assert_response :success
    session_id = @request.session_options[:id]
    assert session_id
  end
end

