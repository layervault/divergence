require 'test_helper'

class TestWebook < Test::Unit::TestCase
  def test_is_webhook
    set_mock_request "master.example.com/divergence-webhook",
      :method => :post

    assert app.is_webhook?

    set_mock_request "example.com/divergence-webhook",
      :method => :post

    assert app.is_webhook?
  end

  def test_isnt_webhook
    set_mock_request "example.com/test",
      :method => :post

    assert !app.is_webhook?

    set_mock_request "example.com/divergence-webhook",
      :method => :get

    assert !app.is_webhook?

    set_mock_request "example.com/foo/bar/divergence-webhook",
      :method => :post
  end
end