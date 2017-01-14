require 'test_helper'

class RemindsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reminds_index_url
    assert_response :success
  end

  test "should get new" do
    get reminds_new_url
    assert_response :success
  end

  test "should get create" do
    get reminds_create_url
    assert_response :success
  end

  test "should get update" do
    get reminds_update_url
    assert_response :success
  end

  test "should get edit" do
    get reminds_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get reminds_destroy_url
    assert_response :success
  end

end
