CLOUD_PROVIDER ?=
VCS_PROVIDER ?=

default: help

.PHONY: help
help: ## print targets and their descrptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: fmt
fmt: ## terraform fmt
	terraform fmt -recursive -write .

.PHONY: validate
validate: ## terraform validate
	@for dir in $(shell find . -name "*.tf" -not -path "*.terraform*" -printf '%h ' | uniq); do \
		echo "====> $$dir"; \
		terraform -chdir=$$dir init -backend=false || exit 1; \
		terraform -chdir=$$dir validate || exit 1; \
	done

.PHONY: generate
generate:
	@rm -Rf tmp
	@mkdir tmp

ifeq ($(CLOUD_PROVIDER), )
	@echo "CLOUD_PROVIDER envvar must be set"
	@exit 1
endif

ifeq ($(VCS_PROVIDER), )
	@echo "VCS_PROVIDER envvar must be set"
	@exit 1
endif

	@if ! test -d common/cloud/${CLOUD_PROVIDER}; then echo "Cannot find directory: common/cloud/${CLOUD_PROVIDER}" && exit 1; fi
	@if ! test -d common/vcs/${VCS_PROVIDER}; then echo "Cannot find directory: common/vcs/${VCS_PROVIDER}" && exit 1; fi
	@if ! test -d templates/${CLOUD_PROVIDER}-${VCS_PROVIDER}; then echo "Cannot find directory: templates/${CLOUD_PROVIDER}-${VCS_PROVIDER}" && exit 1; fi

	@cp -r common/templates/* tmp
	@cp -r common/cloud/${CLOUD_PROVIDER}/* tmp
	@cp -r common/vcs/${VCS_PROVIDER}/* tmp
	@cp -r templates/${CLOUD_PROVIDER}-${VCS_PROVIDER}/* tmp
