require 'test_helper'
require 'github_repo_history'

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

  it "fetches history" do
    @subject.send(:fetch)
    assert_equal 97, @subject.commit_history.size
  end

  it "handles fetching errors by flushing out history" do
    @subject.instance_variable_set('@commit_history', %w(some fake data))
    mock_response = Net::HTTPForbidden.new '1.0', '403', 'rate limit exceeded'
    Net::HTTP.stub :get_response, mock_response do
      assert_raises { @subject.send(:fetch) }
    end
    assert_empty @subject.instance_variable_get('@commit_history')
  end

  it "parses fetched history" do
    @subject.send(:parse)
    assert_empty @subject.commits_per_author

    @subject.instance_variable_set('@commit_history', JSON.parse(File.read('test/fixtures/response.json')))
    @subject.send(:parse)
    commits_sum = @subject.commits_per_author.values.map { |v| v[:commit_count] }.sum
    assert_equal 30, commits_sum
  end

  it "exports parsed history" do
    exported_filename = 'exports/braspag-rest-19691231-210000.txt'
    File.delete(exported_filename) if File.exists?(exported_filename)
    refute File.exists?(exported_filename)

    @subject.instance_variable_set('@commits_per_author', {
      'dipnlik@gmail.com' => {
        name: 'Alexandre Lima',
        email: 'dipnlik@gmail.com',
        login: 'dipnlik',
        avatar_url: 'http://example.com/dipnlik.png',
        commit_count: 1
      },
      'otheruser@example.com' => {
        name: 'Other User',
        email: 'otheruser@example.com',
        commit_count: 3
      },
      'rando@example.com' => { commit_count: 2 }
    })
    Time.stub :now, Time.at(0) do
      @subject.send(:export)
      assert File.exists?(exported_filename)
    end

    assert_equal [
      "Other User;otheruser@example.com;;;3",
      ";;;;2",
      "Alexandre Lima;dipnlik@gmail.com;dipnlik;http://example.com/dipnlik.png;1"
    ], File.read(exported_filename).split("\n")
  end

  it "can perform all steps in sequence" do
    @called_methods = []
    mock = Minitest::Mock.new
    def mock.fake_call(method_name)
      called_methods << method_name
    end
    3.times { mock.expect :called_methods, @called_methods }

    @subject.stub :fetch, mock.fake_call(:fetch) do
      @subject.stub :parse, mock.fake_call(:parse) do
        @subject.stub :export, mock.fake_call(:export) do
          @subject.perform
        end
      end
    end

    assert_equal [:fetch, :parse, :export], @called_methods
  end
end

Minitest.after_run do
  puts %x(which -s curl && curl --silent -i https://api.github.com/repos/Dinda-com-br/braspag-rest/commits | grep X-RateLimit-Remaining:)
end
