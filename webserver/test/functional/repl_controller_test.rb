require 'test_helper'

class ReplControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "new command" do
    post :new_command
    assert_response :success
  end

  test "new command returns json" do
    @request.env['HTTP_ACCEPT'] = "application/json"
    
    post :new_command,
      :command => {:command => "foo()"}.to_json
    assert_response :success
  end

  test "push new command of code saves cookie" do
    @request.session_options[:id] = 123
    post :new_command
    assert_response :success
    assert cookies['session_id']
  end

  test "get response fails if not session cookie" do
    get :get_response
    assert_response :success
  end

  test "get response fails if not session cookie json" do
    @request.env['HTTP_ACCEPT'] = "application/json"
    get :get_response
    assert_response :success

    js = JSON.parse(@response.body)
    assert_equal 1, js['error']
  end

  test "new command returns json full" do
    @request.env['HTTP_ACCEPT'] = "application/json"
    
    post :new_command,
      :command => {:command => "1"}.to_json
    assert_response :success

    begin
    js = JSON.parse(@response.body)
    rescue JSON::ParserError
      fail "Cannot parse JSON:\n" + @response.body
    end
    assert_equal 0, js['error']
    assert_equal "1", js['answer']
  end

end
