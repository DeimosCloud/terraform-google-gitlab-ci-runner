mkdir -p /etc/gitlab-runner
cat > /etc/gitlab-runner/config.toml <<- EOF

${runners_config}

EOF

cat > /etc/gitlab-runner/service-account.json <<- EOF
${runners_service_account_json}
EOF

# Setup Monitoring for instances
if [[ `echo ${runners_enable_monitoring}` == "true" ]]; then
  curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
  bash add-monitoring-agent-repo.sh --also-install
  service stackdriver-agent start

  # using 'EOF' to avoid variable expansion in the bash script https://stackoverflow.com/a/27921346/7167357
  cat > /etc/stackdriver/collect-running-jobs.sh <<- 'EOF'
${collectd_exporter}
EOF
  chmod +x /etc/stackdriver/collect-running-jobs.sh 

  # Autoscaling requires the labels to contain the instance ID and Zone. We can get those from the metadata
  # https://cloud.google.com/compute/docs/autoscaler/scaling-stackdriver-monitoring-metrics#choose_a_valid_custom_metric
  instance_id="$(curl http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google --silent)"
  full_instance_zone="$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google --silent)"
  instance_zone=`echo $full_instance_zone|cut -d "/" -f 4`
  cat > /etc/stackdriver/collectd.d/gitlab-runner.conf <<- EOF
${collectd_conf}
EOF

  service stackdriver-agent restart
fi

${pre_install}

curl --fail --retry 6 -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
yum install ${gitlab_runner_version} -y

if [[ `echo ${runners_executor}` == "docker" ]]
then
  echo 'installing docker'
    curl --fail --retry 6 -L https://get.docker.com/ |bash
    usermod -a -G docker gitlab-runner
    service docker start
else
  if [[ `echo ${docker_machine_download_url}` == "" ]]
  then
    # Download Docker machine from Gitlab Fork with fixes and maintenances
    curl --fail --retry 6 -L https://gitlab-docker-machine-downloads.s3.amazonaws.com/main/docker-machine-`uname -s`-`uname -m` -o /tmp/docker-machine
  else
    curl --fail --retry 6 -L ${docker_machine_download_url} -o /tmp/docker-machine
  fi

  chmod +x /tmp/docker-machine && \
    mv /tmp/docker-machine /usr/local/bin/docker-machine && \
    ln -s /usr/local/bin/docker-machine /usr/bin/docker-machine
  docker-machine --version

  # Create a dummy machine so that the cert is generated properly
  # See: https://gitlab.com/gitlab-org/gitlab-runner/issues/3676
  # See: https://github.com/docker/machine/issues/3845#issuecomment-280389178
  export USER=root
  export HOME=/root
  suffix="$(< /dev/urandom tr -dc _a-z-0-9 | head -c6)"
  dummymachine="${prefix}-gitlab-runner-dummy-machine-$suffix"
  echo "Verifying docker-machine and generating SSH keys ahead of time."
  docker-machine create --driver google \
      --google-project ${gcp_project} \
      --google-machine-type f1-micro \
      --google-zone ${gcp_zone} \
      --google-service-account ${runners_service_account} \
      --google-scopes https://www.googleapis.com/auth/cloud-platform \
      --google-disk-type pd-ssd \
      --google-tags ${runners_tags} \
      --google-network ${runners_network} \
      %{~ if runners_subnetwork != "" ~}
      --google-subnetwork ${runners_subnetwork} \
      %{~ endif ~}
      $dummymachine
  docker-machine rm -y $dummymachine
  unset HOME
  unset USER
fi

if [[ "${runners_install_docker_credential_gcr}" == "true" ]]
then
  curl -s https://api.github.com/repos/GoogleCloudPlatform/docker-credential-gcr/releases/latest |\
    grep "browser_download_url.*linux_amd64" | cut -d : -f 2,3 | tr -d \" | xargs  curl -fsSL | \
    tar -xzf - docker-credential-gcr --to-stdout \
    > /usr/local/bin/docker-credential-gcr && chmod +x /usr/local/bin/docker-credential-gcr
  su gitlab-runner -c 'docker-credential-gcr configure-docker -include-artifact-registry'
fi

# Install jq if not exists
if ! [ -x "$(command -v jq)" ]; then
  yum install jq -y
fi

# Get existing token from local file, if exists. Else register new Runner
touch /etc/gitlab-runner/token
token=$(cat /etc/gitlab-runner/token)
if [[ "$token" == "" ]]
then
  token=$(curl --request POST -L "${runners_gitlab_url}/api/v4/runners" \
    --form "token=${gitlab_runner_registration_token}" \
      %{~ if gitlab_runner_tag_list != "" ~}
    --form "tag_list=${gitlab_runner_tag_list}" \
      %{~ endif ~}
      %{~ if giltab_runner_description != "" ~}
    --form "description=${giltab_runner_description}" \
      %{~ endif ~}
      %{~ if gitlab_runner_locked_to_project != "" ~}
    --form "locked=${gitlab_runner_locked_to_project}" \
      %{~ endif ~}
      %{~ if gitlab_runner_run_untagged != "" ~}
    --form "run_untagged=${gitlab_runner_run_untagged}" \
      %{~ endif ~}
      %{~ if gitlab_runner_maximum_timeout != "" ~}
    --form "maximum_timeout=${gitlab_runner_maximum_timeout}" \
      %{~ endif ~}
      %{~ if gitlab_runner_access_level != "" ~}
    --form "access_level=${gitlab_runner_access_level}" \
      %{~ endif ~}
    | jq -r .token)

# Store Token in Google Secret Manager
echo $token > /etc/gitlab-runner/token
fi

sed -i.bak s/__TOKEN_BE_REPLACED__/`echo $token`/g /etc/gitlab-runner/config.toml

${post_install}

service gitlab-runner restart
chkconfig gitlab-runner on
