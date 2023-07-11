#!/bin/bash

# Set your GitLab token and group ID
TOKEN="YOUR_GITLAB_TOKEN"
GROUP_ID="YOUR_GROUP_ID"
SEARCH_STRING="YOUR_SEARCH_STRING"

# Create an empty JSON array
JSON_ARRAY='[]'

# Get all projects under the group
PROJECTS=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects" | jq -r '.[] | {id: .id, name: .name, ssh_url_to_repo: .ssh_url_to_repo}')

# Loop over each project
for row in $(echo "${PROJECTS}" | jq -r '. | @base64'); do
  # Get the project details
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  PROJECT_ID=$(_jq '.id')
  PROJECT_NAME=$(_jq '.name')
  PROJECT_URL=$(_jq '.ssh_url_to_repo')

  # Clone the project
  git clone $PROJECT_URL

  # Check if the .gitlab-ci.yml file exists
  if [ -f "$PROJECT_NAME/.gitlab-ci.yml" ]; then
    # Search for the string in the .gitlab-ci.yml file
    if grep -q $SEARCH_STRING "$PROJECT_NAME/.gitlab-ci.yml"; then
      # Add the project to the JSON array
      JSON_ARRAY=$(echo $JSON_ARRAY | jq '. += [{"id": "'$PROJECT_ID'", "name": "'$PROJECT_NAME'", "string_exists": "yes"}]')
    fi
  fi

  # Remove the cloned project
  rm -rf $PROJECT_NAME
done

# Write the JSON array to a file
echo $JSON_ARRAY > output.json

















#!/bin/bash

# Set your GitLab token, group ID and search string
TOKEN="YOUR_GITLAB_TOKEN"
GROUP_ID="YOUR_GROUP_ID"
SEARCH_STRING="YOUR_SEARCH_STRING"

# Create an empty JSON array
JSON_ARRAY='[]'

# Get all projects under the group
PROJECTS=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects" | jq -r '.[] | {id: .id, name: .name}')

# Loop over each project
for row in $(echo "${PROJECTS}" | jq -r '. | @base64'); do
  # Get the project details
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  PROJECT_ID=$(_jq '.id')
  PROJECT_NAME=$(_jq '.name')

  # Get the .gitlab-ci.yml file
  GITLAB_CI=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects/$PROJECT_ID/repository/files/%2Egitlab-ci%2Eyml?ref=master" | jq -r '.content' | base64 -d)

  # Search for the string in the .gitlab-ci.yml file
  if echo $GITLAB_CI | grep -q $SEARCH_STRING; then
    # Add the project to the JSON array
    JSON_ARRAY=$(echo $JSON_ARRAY | jq '. += [{"id": "'$PROJECT_ID'", "name": "'$PROJECT_NAME'", "string_exists": "yes"}]')
  fi
done

# Write the JSON array to a file
echo $JSON_ARRAY > output.json



#!/bin/bash

# Set your GitLab token, group ID and search string
TOKEN="YOUR_GITLAB_TOKEN"
GROUP_ID="YOUR_GROUP_ID"
SEARCH_STRING="YOUR_SEARCH_STRING"

# Create a CSV file and add the header
echo "id,name,string_exists" > output.csv

# Get all projects under the group
PROJECTS=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects" | jq -r '.[] | {id: .id, name: .name}')

# Loop over each project
for row in $(echo "${PROJECTS}" | jq -r '. | @base64'); do
  # Get the project details
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  PROJECT_ID=$(_jq '.id')
  PROJECT_NAME=$(_jq '.name')

  # Get the .gitlab-ci.yml file
  GITLAB_CI=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects/$PROJECT_ID/repository/files/%2Egitlab-ci%2Eyml?ref=master" | jq -r '.content' | base64 -d)

  # Search for the string in the .gitlab-ci.yml file
  if echo $GITLAB_CI | grep -q $SEARCH_STRING; then
    # Add the project to the CSV file with "yes"
    echo "$PROJECT_ID,$PROJECT_NAME,yes" >> output.csv
  else
    # Add the project to the CSV file with "no"
    echo "$PROJECT_ID,$PROJECT_NAME,no" >> output.csv
  fi
done



    json_object=$(echo "[{'id': '"$PROJECT_ID"', 'name': '"$PROJECT_NAME"', 'string_exists': 'yes'}]" | jq -c .)

    # Append the JSON object to the array
    JSON_ARRAY=$(echo "$JSON_ARRAY" | jq ". + [$json_object]")
