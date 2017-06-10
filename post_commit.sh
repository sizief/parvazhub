#!/bin/bash
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
#succesful
  curl -X POST --max-time 60 \
    -H "PRIVATE-TOKEN: $SCM_TOKEN" \
    "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/statuses/$OPENSHIFT_BUILD_COMMIT?state=success&context=AbarCloud&description=Tests%20passed&target_url=$BUILD_LOG_URL"

 echo "Exiting with 0 so image can be pushed"
 exit 0

else


  curl -X POST --max-time 60 \
    -H "PRIVATE-TOKEN: $SCM_TOKEN" \
    "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/statuses/$OPENSHIFT_BUILD_COMMIT?state=failed&context=AbarCloud&description=Tests%20failed&target_url=$BUILD_LOG_URL"

 echo "Exiting with 1 so image is not pushed"
 exit 1
fi