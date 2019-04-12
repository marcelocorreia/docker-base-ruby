NAME := base-ruby
#
GITHUB_USER := marcelocorreia
DOCKER_NAMESPACE := marcelocorreia
IMAGE_NAME := $(DOCKER_NAMESPACE)/$(NAME)
GIT_REPO_NAME := docker-$(NAME)
IMAGE_SOURCE_TYPE ?= .alpine
REPO_URL := git@github.com:$(GITHUB_USER)/$(GIT_REPO_NAME).git
SCAFOLD := badwolf
GIT_BRANCH ?= master
GIT_REMOTE ?= origin
RELEASE_TYPE ?= patch
SEMVER_DOCKER ?= marcelocorreia/semver
VERSION_CMD := docker run --rm ruby:alpine ruby -v| awk '{print $$2}'
release: _release
build: _docker-build
push: _docker-push

all-versions:
	@git ls-remote --tags $(GIT_REMOTE)

current-version: _setup-versions
	@echo $(VERSION)


_setup-versions:
	$(eval export VERSION=$(shell $(VERSION_CMD)))

_docker-build: _setup-versions
	docker build -t $(IMAGE_NAME) .
	docker build -t $(IMAGE_NAME):$(VERSION) .
#	$(call  git_push,Post Release Updating auto generated stuff - version: $(CURRENT_VERSION))

_docker-push: _setup-versions
	docker push $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):$(CURRENT_VERSION)

_release: _setup-versions ;$(call  git_push,Releasing $(NEXT_VERSION)) ;$(info $(M) Releasing version $(NEXT_VERSION)...)## Release by adding a new tag. RELEASE_TYPE is 'patch' by default, and can be set to 'minor' or 'major'.
	github-release release -u marcelocorreia -r $(GIT_REPO_NAME) --tag $(NEXT_VERSION) --name $(NEXT_VERSION)
	$(MAKE) _docker-build _docker-push

_initial-release:
	github-release release -u marcelocorreia -r $(GIT_REPO_NAME) --tag 0.0.0 --name 0.0.0

_git-push:
	$(call  git_push,Releasing $(NEXT_VERSION))
_readme:
	$(SCAFOLD) generate --resource-type readme .

define git_push
	-git add .
	-git commit -m "$1"
	-git push
endef