require 'net/https'
require 'json'

response = Net::HTTP.get_response URI("https://api.github.com/repos/Dinda-com-br/braspag-rest/commits")
abort 'Error retrieving history' unless response.is_a? Net::HTTPSuccess

history = JSON.parse response.body

commits_per_author = {}

history.each do |item|
    author = item['commit']['author']
    author_key = author['email']
    author_info = { name: author['name'], email: author['email'], commit_count: 0 }

    commits_per_author[author_key] ||= author_info
    commits_per_author[author_key][:commit_count] += 1
end

p commits_per_author
@commits_per_author = commits_per_author
