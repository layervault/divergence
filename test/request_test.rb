require 'test_helper'

class RequestTest < Test::Unit::TestCase
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

  def test_missing_branch
    status, _, _ = mock_get "idontexist.example.com"
    assert_equal status, 404
  end
end