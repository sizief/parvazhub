require 'net/http'
require 'json'

url = 'https://api.github.com/repos/sizief/parvazhub/commits'
uri = URI(url)
response = Net::HTTP.get(uri)
result = JSON.parse(response)
content = {url: result[0]['html_url'], date: result[0]['commit']['author']['date']}
File.write('git_last_commit', content.to_json)