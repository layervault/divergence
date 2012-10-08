require 'test_helper'

class GitTest < Test::Unit::TestCase
  def force_branch(branch)
    git = Git.open('test/git_root')
    git.reset_hard('HEAD')
    git.checkout branch.to_s, :force => true
  end

  def test_ignore
    force_branch :master
    mock_get 'master.example.com'

    git = Git.open('test/git_root')
    assert_equal "master", git.current_branch

    # and again...
    mock_get 'master.example.com'
    assert_equal 'master', git.current_branch
  end

  def test_switch_branch
    force_branch :master
    mock_get 'branch1.example.com'

    git = Git.open('test/git_root')
    assert_equal 'branch1', git.current_branch
  end

  def test_branch_discover
    force_branch :master
    mock_get 'branch-1.example.com'

    git = Git.open('test/git_root')
    assert_equal 'branch_1', git.current_branch

    mock_get 'branch-with-complex-name-1.example.com'
    assert_equal 'branch_with_complex_name-1', git.current_branch
  end

  def test_dirty_switch
    force_branch :master

    File.open 'test/git_root/test.txt', 'a' do |f|
      f.write 'modifying this'
    end

    mock_get 'branch1.example.com'

    git = Git.open('test/git_root')
    assert_equal 'branch1', git.current_branch
  end

  def test_swap
    force_branch :master
    mock_get "master.example.com"

    assert File.exists? 'test/app_root/test.txt'

    file = File.open 'test/app_root/test.txt'
    contents = file.read.strip
    file.close

    assert_equal "master", contents

    mock_get "branch1.example.com"

    assert File.exists? 'test/app_root/test.txt'
    file = File.open 'test/app_root/test.txt'
    contents = file.read.strip
    file.close

    assert_equal "branch1", contents
  end
end