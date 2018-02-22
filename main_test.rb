require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/mock'
require './main'

describe GithubRepoHistory do
  before do
    @subject = GithubRepoHistory.new
  end

  it "is properly initialized" do
    assert_equal [], @subject.instance_variable_get('@commit_history')
    assert_equal({}, @subject.instance_variable_get('@commits_per_author'))
    assert_equal 'Dinda-com-br/braspag-rest', @subject.instance_variable_get('@repo')

    subject2 = GithubRepoHistory.new('github/scripts-to-rule-them-all')
    assert_equal 'github/scripts-to-rule-them-all', subject2.instance_variable_get('@repo')
  end
end
