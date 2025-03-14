#!/bin/bash

if [[ -z "$1" ]]; then
    echo -e "\e[31mError: Please provide a semver version (e.g., 2025.7.0)"
    exit 1
fi

SEMVER="$1"
MAJOR_MINOR=$(echo "$SEMVER" | cut -d '.' -f 1,2)
PATCH=$(echo "$SEMVER" | cut -d '.' -f 3)

if [[ "$PATCH" == "0" ]]; then
    BRANCH_TYPE="release"
else
    BRANCH_TYPE="hotfix"
fi

SOURCE_BRANCH="develop"
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
TARGET_BRANCH="${BRANCH_TYPE}/${SEMVER}"

git fetch --prune || { echo -e "\e[31mError: Failed to fetch repository updates"; exit 1; }
git branch $TARGET_BRANCH "origin/$SOURCE_BRANCH" || { echo -e "\e[31mError: Failed to create branch"; exit 1; }
git tag $SEMVER $TARGET_BRANCH || { echo -e "\e[31mError: Failed to tag branch"; exit 1; }
git push -u origin $TARGET_BRANCH || { echo -e "\e[31mError: Failed to push release branch to origin"; exit 1; }
git push origin $SEMVER || { echo -e "\e[31mError: Failed to push tag to origin"; exit 1; }
git branch -D $TARGET_BRANCH || { echo -e "\e[31mError: Failed to remove release branch"; exit 1; }

echo -e "\e[32mSuccessfully cut branch $TARGET_BRANCH from $SOURCE_BRANCH"

