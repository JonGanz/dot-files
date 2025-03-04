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

MAIN_BRANCH="main"
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
TARGET_BRANCH="${BRANCH_TYPE}/${SEMVER}"

git fetch --prune || { echo -e "\e[31mError: Failed to fetch from origin"; exit 1; }
git stash save -m "Stashing changes to $CURRENT_BRANCH before merging release $TARGET_BRANCH" || { echo -e "\e[31mError: Failed to stash changes"; exit 1; }

git checkout $MAIN_BRANCH || { echo -e "\e[31mError: Failed to checkout 'main' branch"; exit 1; }
git reset --hard "origin/$MAIN_BRANCH" || { echo -e "\e[31mError: Failed to update 'main' branch"; exit 1; }
git merge --ff-only "origin/$TARGET_BRANCH" || { echo -e "\e[31mError: Failed to merge $TARGET_BRANCH"; exit 1; }
git push origin $MAIN_BRANCH || { echo -e "\e[31mError: Failed to push updated 'main' branch to origin"; exit 1; }
git checkout "$CURRENT_BRANCH" || { echo -e "\e[31mError: Failed to checkout original branch $CURRENT_BRANCH"; exit 1; }
git stash pop || { echo -e "\e[31mError: Failed to pop stashed changes"; exit 1; }

echo -e "\e[32mSuccessfully merged and pushed the $TARGET_BRANCH branch to 'main'"

