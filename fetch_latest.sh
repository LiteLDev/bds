#! /usr/bin/env bash

# Fetch JSON and extract the downloadUrl for serverBedrockWindows
download_url=$(curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0' -s "https://net-secondary.web.minecraft-services.net/api/v1.0/download/links" | \
grep -oP '"downloadType":\s*"serverBedrockWindows".*?"downloadUrl":\s*"\K[^"]+')

if [[ -z "$download_url" ]]; then
    echo "Failed to fetch downloadUrl for serverBedrockWindows."
    exit 1
fi

echo "Download URL: $download_url"

# Extract the version number using regex
if [[ $download_url =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    version="${BASH_REMATCH[0]}"
    echo "Parsed version: $version"
else
    echo "Failed to extract version number from the download_url."
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
