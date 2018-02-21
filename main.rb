require 'net/https'
require 'json'

class GithubRepoHistory
  def initialize
    @commit_history = []
    @commits_per_author = {}
  end

  def fetch
    commit_history = []
    page = 1

    loop do
      response = Net::HTTP.get_response URI("https://api.github.com/repos/Dinda-com-br/braspag-rest/commits?page=#{page}")
      abort 'Error retrieving history' unless response.is_a? Net::HTTPSuccess
    
      history_page = JSON.parse(response.body)
      break if history_page.empty?
      commit_history += history_page
    
      page += 1
    end

    @commit_history = commit_history
  end

  def parse
    commits_per_author = {}

    @commit_history.each do |item|
      author = item['commit']['author']
      author_key = author['email']
      author_info = { name: author['name'], email: author['email'], commit_count: 0 }
    
      commits_per_author[author_key] ||= author_info
      commits_per_author[author_key][:commit_count] += 1
    end

    @commits_per_author = commits_per_author
  end
end
