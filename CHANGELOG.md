# Changelog

All notable changes to this project will be documented in this file.

### [1.2.1](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.2.0...v1.2.1) (2022-06-12)


### Bug Fixes

* fix cache name and optional docker-machine firewall creation ([#13](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/13)) ([1d53300](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/1d5330027c504ed2c5c0401387551f65acc3de77))

## [1.2.0](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.1.2...v1.2.0) (2022-05-19)


### Features

* Conditionally create node pool ([#12](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/12)) ([2b8b64d](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/2b8b64d073eb71540fb8ce2d92c4f62ff2e4c873))

### [1.1.2](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.1.1...v1.1.2) (2022-05-18)


### Bug Fixes

* moved cache and gke-runner submodule into the folders directory ([#11](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/11)) ([8443244](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/8443244ec80264a63e583f36dc21e4b7ff8babbc))

### [1.1.1](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.1.0...v1.1.1) (2022-05-18)


### Bug Fixes

* changed module.cache[0].cache_bucket_name -> module.cache.cache_bucket_name  ([#10](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/10)) ([0d1fa07](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/0d1fa07fe415ba3c587eb4f654a24a9e1f2461cb))

## [1.1.0](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.0.11...v1.1.0) (2022-05-18)


### Features

* Added module for cache and kubernetes ([#8](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/8)) ([0978d21](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/0978d215a28378b9f194fe29d9aaf44fb94d0567))


### Bug Fixes

* use the same image for spinning up dummy machine and update default runner machine image to COS ([7c24b17](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/7c24b17f8997d6558e917ee8f095422d29b5cc43))

### [1.0.11](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.0.10...v1.0.11) (2022-04-29)


### Bug Fixes

* update runner machine image to ubuntu-2004 to fix docker installation ([093ba99](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/093ba995d1a67d73be76e365a06a4b5c8d2b93d6))

### [1.0.10](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.0.9...v1.0.10) (2022-04-29)


### Bug Fixes

* use internal Ip for dummy runner so that firewall rule works ([f57a91f](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/f57a91fd66357ab7805db8efc142dad74cf72893))

### [1.0.9](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.0.8...v1.0.9) (2022-04-05)


### Bug Fixes

* create additional  docker-machines firewall rule to account for multiple deployments overriding each other ([#5](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/5)) ([9c12581](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/9c125815248c4d2f79e871e835c1b1aeb0108d91))

### [1.0.8](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/compare/v1.0.7...v1.0.8) (2022-03-16)


### Bug Fixes

* registration should use internal IP so that we can use tags for firewall rules ([#4](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/issues/4)) ([8926850](https://github.com/DeimosCloud/terraform-google-gitlab-ci-runner/commit/8926850999fec929ca80664708dd95aacdd4e698))
