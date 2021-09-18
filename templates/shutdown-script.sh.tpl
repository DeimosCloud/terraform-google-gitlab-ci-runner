#!/bin/bash
logger "Unregistering Gitlab Runner "
# Get existing token from local file, if exists
token=$(cat /etc/gitlab-runner/token)
if [[ "$token" != "" ]]; then
  curl -sS --request DELETE "${runners_gitlab_url}/api/v4/runners" --form "token=$token" 2>&1 | logger &
fi
