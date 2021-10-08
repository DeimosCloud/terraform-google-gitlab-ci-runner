# Fetches gitlab_runner_jobs metrics from the gitlab runner metrics endpoint. Defaults value to 0 if not set
# https://gitlab.com/gitlab-org/gitlab-runner/-/issues/25845
HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname)}"
INTERVAL="${COLLECTD_INTERVAL:-15}"

while sleep "$INTERVAL"; do
  JOBS=$(curl -s 127.0.0.1:9252/metrics | grep "gitlab_runner_jobs{" | awk '{ SUM += $2} END { print SUM }')
  JOBS=${JOBS:-0}
  echo "PUTVAL \"$HOSTNAME/exec-gitlab_runner/gauge-jobs\" interval=$INTERVAL N:$JOBS"
done
