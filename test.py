#!/bin/bash

GITLAB_TOKEN="YOUR_GITLAB_TOKEN"
GITLAB_USERNAME="YOUR_GITLAB_USERNAME"
GROUP_ID="YOUR_GROUP_ID"
GITLAB_API_URL="https://gitlab.com/api/v4" # Change this if you're using a self-hosted GitLab instance

# Get the total number of pages
total_pages=$(curl -s --head --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/groups/$GROUP_ID/projects?per_page=100" | grep -oP '(?<=X-Total-Pages: )\d+')

# Iterate through all pages and clone the repositories
for page in $(seq 1 $total_pages); do
  repos=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/groups/$GROUP_ID/projects?per_page=100&page=$page")
  for repo in $(echo "$repos" | jq -r '.[] | .ssh_url_to_repo'); do
    git clone "$repo"
  done
done

