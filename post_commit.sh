# Depending on your image, you might or might not need to start this file with "#!/bin/bash"
# Try without it, and if it doesn't work, add it.

# Update the following line with whatever command you use to run your tests (e.g. `npm test`)
TEST_COMMAND="bundle exec rails test"

# Update the following line with your BuildConfig name, you can see all BuildConfigs by running `oc get buildconfigs`
BUILD_CONFIG_NAME="flight-search"

# Update the following line with your GitHub/GitLab details, delete the line that doesn't apply
GITLAB_PROJECT_ID=2179063

# Build log URL, do no update the following line
BUILD_LOG_URL="https://dashboard.abarcloud.com/console/project/$OPENSHIFT_BUILD_NAMESPACE/browse/builds/$BUILD_CONFIG_NAME/$OPENSHIFT_BUILD_NAME?tab=logs"

# Notify GitHub/GitLab of the status
$TEST_COMMAND
if [[ $? == 0 ]]
then

 # Uncomment the following section as required to notify of tests passing

 # GitHub example:
 # See https://developer.github.com/v3/repos/statuses/#create-a-status for more info
 # curl "https://api.github.com/repos/$GITHUB_REPO/statuses/$OPENSHIFT_BUILD_COMMIT?access_token=$SCM_TOKEN" \
 #   -H "Content-Type: application/json" \
 #   -X POST --max-time 60 \
 #   -d "{\"state\": \"success\", \"context\": \"AbarCloud\", \"description\": \"Tests passed\", \"target_url\": \"$BUILD_LOG_URL\"}"

 # GitLab example:
 # See https://docs.gitlab.com/ce/api/commits.html#post-the-build-status-to-a-commit for more info
  curl -X POST --max-time 60 \
    -H "PRIVATE-TOKEN: $SCM_TOKEN" \
    "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/statuses/$OPENSHIFT_BUILD_COMMIT?state=success&context=AbarCloud&description=Tests%20passed&target_url=$BUILD_LOG_URL"

 echo "Exiting with 0 so image can be pushed"
 exit 0

else

 # Uncomment the following section as required to notify of tests failing

 # GitHub example:
 # See https://developer.github.com/v3/repos/statuses/#create-a-status for more info
 # curl "https://api.github.com/repos/$GITHUB_REPO/statuses/$OPENSHIFT_BUILD_COMMIT?access_token=$SCM_TOKEN" \
 #   -H "Content-Type: application/json" \
 #   -X POST --max-time 60 \
 #   -d "{\"state\": \"failure\", \"context\": \"AbarCloud\", \"description\": \"Tests failed\", \"target_url\": \"$BUILD_LOG_URL\"}"

 # GitLab example:
 # See https://docs.gitlab.com/ce/api/commits.html#post-the-build-status-to-a-commit for more info
  curl -X POST --max-time 60 \
    -H "PRIVATE-TOKEN: $SCM_TOKEN" \
    "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/statuses/$OPENSHIFT_BUILD_COMMIT?state=failed&context=AbarCloud&description=Tests%20failed&target_url=$BUILD_LOG_URL"

 echo "Exiting with 1 so image is not pushed"
 exit 1
fi