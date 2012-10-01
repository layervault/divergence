require 'test_helper'

class RequestTest < Test::Unit::TestCase
  def test_passthru
    set_request_addr "example.com"

    get "/"
    follow_redirect!

    assert last_response.ok?
  end
end