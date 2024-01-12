#! /usr/bin/env bash

# Fetch the download link for the latest version of BDS
response=$(curl -s https://mc-bds-helper.vercel.app/api/latest)
echo "Got response from the API: $response"

# Extract the version number using regex
if [[ $response =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    version="${BASH_REMATCH[0]}"
    echo "Parsed version: $version"
else
    echo "Failed to extract version number from the response."
    exit 1
fi

# Compare the last line of versions.txt with the latest version
last_recorded_version=$(tail -n 1 versions.txt)
echo "Last recorded version: $last_recorded_version"

if [[ $last_recorded_version == $version ]]; then
    echo "The latest version is already recorded."
    exit 0
fi

# Append the latest version to versions.txt
echo "$version" >> versions.txt

# Git commit and push
git add versions.txt
git commit -m "Add latest version: $version"
git push
