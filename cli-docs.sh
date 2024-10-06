#!/bin/bash

HARBOR_CLI_REPO_API="https://api.github.com/repos/goharbor/harbor-cli/contents/doc/cli-docs"
WEBSITE_REPO_API="https://api.github.com/repos/goharbor/website/contents/docs/cli-docs?ref=release-cli-docs"

echo "Fetching markdown files from harbor-cli repo..."
CLI_FILES=$(curl -s $HARBOR_CLI_REPO_API | jq -r '.[] | select(.name | endswith(".md")) | .name')

echo "Fetching markdown files from website repo..."
WEBSITE_FILES=$(curl -s $WEBSITE_REPO_API | jq -r '.[] | select(.name | endswith(".md")) | .name')

MISSING_FILES=()
for FILE in $CLI_FILES; do
    if ! echo "$WEBSITE_FILES" | grep -q "$FILE"; then
        MISSING_FILES+=("$FILE")
    fi
done

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "No missing files. All files are up to date."
else
    echo "Missing files found: ${MISSING_FILES[@]}"
    for FILE in "${MISSING_FILES[@]}"; do
        DOWNLOAD_URL="https://raw.githubusercontent.com/goharbor/harbor-cli/main/doc/cli-docs/$FILE"
        echo "Downloading $FILE..."
        curl -s $DOWNLOAD_URL -o "docs/cli-docs/$FILE"
        echo "Copied $FILE to website repository."
    done
fi
