NAME := $(shell basename $(shell pwd) | sed 's/docker-//g')
M := $(shell printf "\033[34;1m▶\033[0m")
GITHUB_USER := marcelocorreia
DOCKER_NAMESPACE := marcelocorreia
IMAGE_NAME := $(DOCKER_NAMESPACE)/$(NAME)
GIT_REPO_NAME := $(shell basename $(shell pwd))
IMAGE_SOURCE_TYPE ?= .alpine
REPO_URL := git@github.com:$(GITHUB_USER)/$(GIT_REPO_NAME).git
SCAFOLD := badwolf
GIT_BRANCH ?= master
GIT_REMOTE ?= origin

VERSION_CMD := docker run --rm ruby:alpine ruby -v| awk '{print $$2}'

open-page: _open-page
release: _release
build: _docker-build
push: _docker-push
all-versions: _all-versions
current-version: _current-version
info: ;$(info $(M) TODO)

_all-versions:
	@git ls-remote --tags $(GIT_REMOTE)

_current-version: _setup-versions
	@echo $(VERSION)

_setup-versions:
	$(eval export VERSION=$(shell $(VERSION_CMD)))

_docker-build: _setup-versions _readme ;$(info $(M) Building $(NAME))
	docker build -t $(IMAGE_NAME) .
	docker build -t $(IMAGE_NAME):$(VERSION) .

_docker-push: _setup-versions
	docker push $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):$(CURRENT_VERSION)

_release: _setup-versions ;$(call  git_push,Releasing $(NEXT_VERSION)) ;$(info $(M) Releasing version $(NEXT_VERSION)...)
	github-release release -u marcelocorreia -r $(GIT_REPO_NAME) --tag $(VERSION) --name $(VERSION)
	$(MAKE) _docker-build _docker-push

_readme:
	$(SCAFOLD) generate --resource-type readme .
	$(call  git_push,Updating docs)

_open-page:
	open https://github.com/$(GITHUB_USER)/$(GIT_REPO_NAME).git

define git_push
	-git add .
	-git commit -m "$1"
	-git push
endef