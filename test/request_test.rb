require 'test_helper'

class RequestTest < Test::Unit::TestCase
  def test_passthru
    set_request_addr "example.com"

    get "/"
    follow_redirect!

    assert last_response.ok?
  end

  def test_has_subdomain
    set_mock_request "master.example.com"
    assert app.req.has_subdomain?
  end

  def test_no_subdomain
    set_mock_request "example.com"
    assert !app.req.has_subdomain?
  end

  def test_branch
    set_mock_request "master.example.com"
    assert_equal app.req.branch, "master"
  end
end