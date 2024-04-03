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
