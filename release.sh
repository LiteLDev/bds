#! /usr/bin/env bash

TOOTH_TEMPLATE=$(cat tooth.template.json)
VERSIONS=$(cat versions.txt)

for VERSION in $VERSIONS; do
    BDS_VERSION=$VERSION # x.y.z.w
    TOOTH_VERSION=$(echo $BDS_VERSION | cut -d. -f1-3) # x.y.z

    # If this version is already tagged, skip it
    if git rev-parse v$TOOTH_VERSION >/dev/null 2>&1; then
        echo "Skipping $TOOTH_VERSION"
        continue
    fi

    git reset --hard
    git checkout -b release $(git rev-list --max-parents=0 HEAD)

    # Replace every <BDS_VERSION> with $BDS_VERSION and every <TOOTH_VERSION> with $TOOTH_VERSION
    TOOTH_CONTENT=$TOOTH_TEMPLATE
    TOOTH_CONTENT=${TOOTH_CONTENT//<BDS_VERSION>/$BDS_VERSION}
    TOOTH_CONTENT=${TOOTH_CONTENT//<TOOTH_VERSION>/$TOOTH_VERSION}

    echo "$TOOTH_CONTENT" > tooth.json

    # Copy README.md and logo.png from main branch
    git checkout main README.md logo.png

    # Commit and push
    git add tooth.json README.md logo.png
    git commit -m "Release $TOOTH_VERSION"
    git tag v$TOOTH_VERSION

    # Clean up
    git checkout main
    git branch -D release
done

git push --tags origin
