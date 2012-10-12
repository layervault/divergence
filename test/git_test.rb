require 'test_helper'

class GitTest < Test::Unit::TestCase
  def test_ignore
    mock_get 'master.example.com'

    assert_equal "master", active_branch

    # and again...
    mock_get 'master.example.com'
    assert_equal 'master', active_branch
  end

  def test_switch_branch
    mock_get 'branch1.example.com'
    assert_equal 'branch1', active_branch
  end

  def test_branch_discover
    mock_get 'branch-1.example.com'
    assert_equal 'branch_1', active_branch

    mock_get 'branch-with-complex-name-1.example.com'
    assert_equal 'branch_with_complex_name-1', active_branch
  end

  def test_dirty_switch
    mock_get "master.example.com"

    File.open 'test/git_root/test.txt', 'a' do |f|
      f.write 'modifying this'
    end

    mock_get 'branch1.example.com'

    assert_equal 'branch1', active_branch
  end

  def test_swap
    mock_get "branch1.example.com"

    assert File.exists? 'test/app_root/test.txt'

    assert_equal "branch1", active_branch
  end
end