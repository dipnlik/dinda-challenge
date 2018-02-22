require 'net/https'
require 'json'

class GithubRepoHistory
  attr_reader :repo, :commit_history, :commits_per_author

  def initialize(repo = 'Dinda-com-br/braspag-rest')
    @repo = repo
    @commit_history = []
    @commits_per_author = {}
  end

  def perform
    self.fetch
    self.parse
    self.export
  end

  protected

  def fetch
    commit_history = []
    page = 1

    loop do
      response = Net::HTTP.get_response URI("https://api.github.com/repos/#{@repo}/commits?page=#{page}")
      unless response.is_a? Net::HTTPSuccess
        @commit_history = []
        raise "Error retrieving history: #{response.inspect}"
      end

      history_page = JSON.parse(response.body)
      break if history_page.empty?

      commit_history += history_page
      page += 1
    end

    @commit_history = commit_history
  end

  def parse
    commits_per_author = {}

    commit_history.each do |item|
      author = item['commit']['author']
      author_key = author['email']
      author_info = { name: author['name'], email: author['email'], commit_count: 0 }

      commits_per_author[author_key] ||= author_info
      commits_per_author[author_key][:commit_count] += 1
    end

    @commits_per_author = commits_per_author
  end

  def export
    output = commits_per_author.values.map do |v|
      [ v[:name], v[:email], v[:commit_count] ].join(';')
    end

    _, repo_name = repo.split('/')
    timestamp = Time.now.strftime '%Y%m%d-%H%M%S'

    File.open("exports/#{repo_name}-#{timestamp}.txt", 'w+') { |f| f.puts output }
  end
end
