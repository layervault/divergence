require 'test_helper'

class WebhookTest < Test::Unit::TestCase
  def test_detect
    mock_get "master.example.com"
    status, _, body = mock_webhook :master

    assert_equal 200, status
    assert_equal ["OK"], body
  end

  def test_ignore
    status, _, body = mock_webhook 'webhook-ignore'

    assert_equal 200, status
    assert_equal ["IGNORE"], body
  end
end