#! /usr/bin/env bash

PACKAGE_TEMPLATE=$(cat lip.template.toml)
VERSIONS=$(cat versions.txt)

for VERSION in $VERSIONS; do
    BDS_VERSION=$VERSION # x.y.z.w
    PACKAGE_VERSION=$(echo $BDS_VERSION | cut -d. -f1-3) # x.y.z

    # If this version is already tagged, skip it
    if git rev-parse v$PACKAGE_VERSION >/dev/null 2>&1; then
        echo "Skipping $PACKAGE_VERSION"
        continue
    fi

    git reset --hard
    git checkout -b release $(git rev-list --max-parents=0 HEAD)

    # Replace every <BDS_VERSION> with $BDS_VERSION and every <PACKAGE_VERSION> with $PACKAGE_VERSION
    PACKAGE_CONTENT=$PACKAGE_TEMPLATE
    PACKAGE_CONTENT=${PACKAGE_CONTENT//<BDS_VERSION>/$BDS_VERSION}
    PACKAGE_CONTENT=${PACKAGE_CONTENT//<PACKAGE_VERSION>/$PACKAGE_VERSION}

    echo "$PACKAGE_CONTENT" > lip.toml

    # The release branch starts from the initial commit, which still has tooth.json
    git rm -q --ignore-unmatch tooth.json tooth.template.json

    # Copy README.md and logo.png from main branch
    git checkout main README.md logo.png

    # Commit and push
    git add lip.toml README.md logo.png
    git commit -m "Release $PACKAGE_VERSION"
    git tag v$PACKAGE_VERSION

    # Clean up
    git checkout main
    git branch -D release
done

git push --tags origin
