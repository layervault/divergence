require 'test_helper'

class GitTest < Test::Unit::TestCase
  def force_branch(branch)
    git = Git.open('test/git_root')
    git.reset_hard('HEAD')
    git.branch(branch.to_s).checkout
  end

  def test_ignore
    force_branch :master
    mock_get 'master.example.com'

    git = Git.open('test/git_root')
    assert git.branch('master').current

    # and again...
    mock_get 'master.example.com'
    assert git.branch('master').current
  end

  def test_switch_branch
    force_branch :master
    mock_get 'branch1.example.com'

    git = Git.open('test/git_root')
    assert git.branch('branch1').current
  end

  def test_dirty_switch
    force_branch :master

    File.open 'test/git_root/test.txt', 'a' do |f|
      f.write 'modifying this'
    end

    mock_get 'branch1.example.com'

    git = Git.open('test/git_root')
    assert git.branch('branch1').current
  end

  def test_swap
    force_branch :master
    mock_get "master.example.com"

    assert File.exists? 'test/app_root/test.txt'

    file = File.open 'test/app_root/test.txt'
    contents = file.read.strip
    file.close

    assert_equal contents, "master"

    mock_get "branch1.example.com"

    assert File.exists? 'test/app_root/test.txt'
    file = File.open 'test/app_root/test.txt'
    contents = file.read.strip
    file.close

    assert_equal contents, "branch1"
  end
end