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




    #!/bin/bash

# Set your GitLab token, group ID and search string
TOKEN="YOUR_GITLAB_TOKEN"
GROUP_ID="YOUR_GROUP_ID"
SEARCH_STRING="YOUR_SEARCH_STRING"

# Create a CSV file and add the header
echo "id,name,string_exists" > output.csv

# Initialize the page number
PAGE=1

# Loop over each page
while true; do
  # Get the projects on the current page
  PROJECTS=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?page=$PAGE&per_page=100" | jq -r '.[] | {id: .id, name: .name}')

  # Break the loop if there are no more projects
  if [ -z "$PROJECTS" ]; then
    break
  fi

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

  # Increment the page number
  PAGE=$((PAGE + 1))
done
















#!/bin/bash

usage() {
if [ $# -ne 4 ]
then
        echo "ERROR: Incorrect usage "
        echo "Usage :- $0 gitlab-private-token gitlab-group-id project-id-file-name search-string"
        exit 1
fi
}

usage $*

TOKEN=$1
GROUP_ID=$2
FILE_NAME=$3
SEARCH_STRING=$4

total_pages=`curl --head -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100" | grep -i "X-Total-Pages" | sed 's|X-Total-Pages: ||g' | tr -d '\r'`
rm $FILE_NAME
for (( ctr=1; ctr<=$total_pages; ctr++ ))
do
   echo 'Retrieving the details for the group - page '$ctr
   curl -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100&page="$ctr | jq '.[] | [.id,.name,.last_activity_at,.archived] | @csv' >> $FILE_NAME
done

# Create a CSV file and add the header
echo "id,name,string_exists" > output.csv

# Read the project IDs from the CSV file
PROJECT_IDS=$(cut -d',' -f1 $FILE_NAME)

# Loop over each project ID
for PROJECT_ID in $PROJECT_IDS; do
  # Get the project name
  PROJECT_NAME=$(grep $PROJECT_ID $FILE_NAME | cut -d',' -f2)

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




#!/bin/bash

usage() {
if [ $# -ne 4 ]
then
        echo "ERROR: Incorrect usage "
        echo "Usage :- $0 gitlab-private-token gitlab-group-id project-id-file-name search-string"
        exit 1
fi
}

usage $*

TOKEN=$1
GROUP_ID=$2
FILE_NAME=$3
SEARCH_STRING=$4

total_pages=$(curl --head -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100" | grep -i "X-Total-Pages" | sed 's|X-Total-Pages: ||g' | tr -d '\r')
rm "$FILE_NAME"
for ((ctr=1; ctr<=$total_pages; ctr++))
do
   echo "Retrieving the details for the group - page $ctr"
   curl -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100&page=$ctr" | jq '.[] | [.id,.name,.last_activity_at,.archived] | @csv' >> "$FILE_NAME"
done

# Create a CSV file and add the header
echo "id,name,last_activity_at,archived,string_exists" > output.csv

# Read the project IDs, names, last_activity_at, and archived from the CSV file
while IFS=, read -r project_id project_name last_activity_at archived; do
  # Get the .gitlab-ci.yml file
  gitlab_ci=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects/$project_id/repository/files/%2Egitlab-ci%2Eyml?ref=master" | jq -r '.content' | base64 -d)

  # Search for the string in the .gitlab-ci.yml file
  if echo "$gitlab_ci" | grep -q "$SEARCH_STRING"; then
    # Add the project to the CSV file with "yes"
    echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"yes\"" >> output.csv
  else
    # Add the project to the CSV file with "no"
    echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"no\"" >> output.csv
  fi
done < "$FILE_NAME"

echo "Project details and search results have been saved to output.csv"


while IFS=, read -r id name last_activity archived
    do
        # Search for the strings in the .gitlab-ci.yml file
        content=$(curl --header "PRIVATE-TOKEN: $1" "https://gitlab.com/api/v4/projects/$id/repository/files/%2Egitlab-ci%2Eyml?ref=master" | jq -r '.content' | base64 -d)
        if echo "$content" | grep -q "$4"; then
            echo "yes,$id,$name" >> results.csv
        elif echo "$content" | grep -q "$5"; then
            echo "automated,$id,$name" >> results.csv
        else
            echo "no,$id,$name" >> results.csv
        fi
    done <<< "$projects"




#!/bin/bash

usage() {
if [ $# -ne 4 ]
then
        echo "ERROR: Incorrect usage "
        echo "Usage :- $0 gitlab-private-token gitlab-group-id project-id-file-name search-string"
        exit 1
fi
}

usage $*

TOKEN=$1
GROUP_ID=$2
FILE_NAME=$3
SEARCH_STRING=$4

total_pages=$(curl --head -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100" | grep -i "X-Total-Pages" | sed 's|X-Total-Pages: ||g' | tr -d '\r')
rm "$FILE_NAME"
for ((ctr=1; ctr<=$total_pages; ctr++))
do
   echo "Retrieving the details for the group - page $ctr"
   curl -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100&page=$ctr" | jq '.[] | [.id,.name,.last_activity_at,.archived] | @csv' >> "$FILE_NAME"
done

# Create a CSV file and add the header
echo "id,name,last_activity_at,archived,string_exists,another_string_exists" > output.csv

# Read the project IDs, names, last_activity_at, and archived from the CSV file
while IFS=, read -r project_id project_name last_activity_at archived; do
  # Get the .gitlab-ci.yml file
  gitlab_ci=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects/$project_id/repository/files/%2Egitlab-ci%2Eyml?ref=master" | jq -r '.content' | base64 -d)

  # Search for the first string in the .gitlab-ci.yml file
  if echo "$gitlab_ci" | grep -q "$SEARCH_STRING"; then
    # Search for the second string in the .gitlab-ci.yml file
    if echo "$gitlab_ci" | grep -q "another_string"; then
      # Add the project to the CSV file with "yes" for both strings
      echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"yes\",\"yes\"" >> output.csv
    else
      # Add the project to the CSV file with "yes" for the first string only
      echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"yes\",\"no\"" >> output.csv
    fi
  else
    # Add the project to the CSV file with "no" for both strings
    echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"no\",\"no\"" >> output.csv
  fi
done < "$FILE_NAME"

echo "Project details and search results have been saved to output.csv"


#!/bin/bash

usage() {
if [ $# -ne 4 ]
then
        echo "ERROR: Incorrect usage "
        echo "Usage :- $0 gitlab-private-token gitlab-group-id project-id-file-name search-string"
        exit 1
fi
}

usage $*

TOKEN=$1
GROUP_ID=$2
FILE_NAME=$3
SEARCH_STRING=$4

total_pages=$(curl --head -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100" | grep -i "X-Total-Pages" | sed 's|X-Total-Pages: ||g' | tr -d '\r')
rm "$FILE_NAME"
for ((ctr=1; ctr<=$total_pages; ctr++))
do
   echo "Retrieving the details for the group - page $ctr"
   curl -H "PRIVATE-TOKEN:$TOKEN" "https://gitlab.com/api/v4/groups/$GROUP_ID/projects?per_page=100&page=$ctr" | jq '.[] | [.id,.name,.last_activity_at,.archived] | @csv' >> "$FILE_NAME"
done

# Create a CSV file and add the header
echo "id,name,last_activity_at,archived,string_exists,another_string_exists" > output.csv

# Read the project IDs, names, last_activity_at, and archived from the CSV file
while IFS=, read -r project_id project_name last_activity_at archived; do
  # Get the .gitlab-ci.yml file
  gitlab_ci=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects/$project_id/repository/files/%2Egitlab-ci%2Eyml?ref=master" | jq -r '.content' | base64 -d)

  # Search for the first string in the .gitlab-ci.yml file
  if echo "$gitlab_ci" | grep -q "$SEARCH_STRING"; then
    # Search for the second string in the .gitlab-ci.yml file
    if echo "$gitlab_ci" | grep -q "another_string"; then
      # Add the project to the CSV file with "yes" for both strings
      echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"yes\",\"yes\"" >> output.csv
    else
      # Add the project to the CSV file with "yes" for the first string only
      echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"yes\",\"no\"" >> output.csv
    fi
  else
    # Add the project to the CSV file with "no" for both strings
    echo "\"$project_id\",\"$project_name\",\"$last_activity_at\",\"$archived\",\"no\",\"no\"" >> output.csv
  fi
done < "$FILE_NAME"

curl -s --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects/$project_id/pipelines?per_page=1" | jq -r '.[0].coverage'


