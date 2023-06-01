##@ Help
.PHONY: help
help: ## Display this help screen
	@awk -v target="$(filter-out $@,$(MAKECMDGOALS))" 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { if (!target || index($$1, target) == 1) printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { getline nextLine; if (!target || index(nextLine, target) == 1) printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build build.dev build.prod
build: ## Build the binary
	@if [ -z "$(build_target)" ]; then \
		$(MAKE) list-targets; \
	else \
		$(MAKE) $(build_target); \
	fi

build.dev: ## Build the binary for developments
	docker buildx build --platform linux/amd64 -t $(DEV_IMAGE_FULL_NAME) -f Dockerfile.dev .

build.prod: ## Build the binary for production
	@echo "Building for production"

list-targets:
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | grep "build." | sed 's/^/make build build_target=/'


include Makefile.*
