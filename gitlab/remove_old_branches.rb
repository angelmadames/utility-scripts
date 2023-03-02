#!/usr/bin/env ruby

require 'http'
require 'json'
require 'cgi'

# Set the maximum age of branches to keep in days
MAX_AGE = 180

# Set the name of the GitLab repository
PROJECT_ID = "991"

# Set the personal access token for the GitLab API
PAT = ""

# Set the base URL for the GitLab API
BASE_URL = "https://git.gbhapps.com/api/v4"

# Set the current time
now = Time.now

# Set the date of branches that are too old
cutoff_date = (now - MAX_AGE * 24 * 60 * 60).strftime("%Y-%m-%dT%H:%M:%S.%LZ")

# Set the HTTP headers for the request
headers = {
  "PRIVATE-TOKEN" => PAT,
}

# Set the URL for the request to get a list of branches
url = "#{BASE_URL}/projects/#{PROJECT_ID}/repository/branches"

# Send the HTTP request to get the list of branches
response = HTTP.get(url, headers: headers)

# Check the status code of the response
if response.code == 200
  # Parse the JSON response
  data = JSON.parse(response.body)

  # Iterate over the list of branches
  data.each do |branch|
    # Check if the branch was last updated before the cutoff date
    if branch["commit"]["committed_date"] < cutoff_date
      # Set the URL for the request to delete the branch
      branch_encoded = CGI.escape(branch['name'])
      url = "#{BASE_URL}/projects/#{PROJECT_ID}/repository/branches/#{branch_encoded}"

      # Send the HTTP request to delete the branch
      response = HTTP.delete(url, headers: headers)

      # Check the status code of the response
      if response.code == 200
        puts "Deleted branch: #{branch['name']}"
      else
        puts "Error deleting branch: #{branch['name']}"
        puts response.body
      end
    end
  end
else
  puts "Error getting list of branches"
end
