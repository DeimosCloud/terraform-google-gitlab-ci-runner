LoadPlugin exec
LoadPlugin match_regex
LoadPlugin target_set
LoadPlugin target_replace
LoadPlugin write_log

<Plugin exec>
  Exec "gitlab-runner" "/etc/stackdriver/collect-running-jobs.sh"
</Plugin>

PreCacheChain "PreCache"
<Chain "PreCache">
  <Rule "get_metrics">
    <Match regex>
      Plugin "^exec$"
      PluginInstance "^gitlab_runner$"
    </Match>
    <Target "set">
      TypeInstance "jobs"
      MetaData "stackdriver_metric_type" "custom.googleapis.com/gitlab_runner/jobs"
      MetaData "label:instance_id" "${instance_id}"
      MetaData "label:instance" "%{host}"
      MetaData "label:zone" "${instance_zone}"
    </Target>
  </Rule>
  # Continue processing metrics in the default "PreCache" chain.
</Chain>
