SOURCERY_MAIN_QUEUE_SCRIPT=./Scripts/Sourcery/MainQueueDispatchDecorator.sh
SOURCERY_WEAK_PROXY_SCRIPT=./Scripts/Sourcery/WeakRefVirtualProxy.sh
SOURCERY_ADAPTER_SCRIPT=./Scripts/Sourcery/SwiftUIAdapterGenerator.sh
SOURCERY_SPY_SCRIPT=./Scripts/Sourcery/SpyGenerator.sh
TUIST_COMMANDS="tuist clean; tuist install; tuist generate"
TUIST_BIN := $(shell if [ -x /opt/homebrew/bin/tuist ]; then echo /opt/homebrew/bin/tuist; else echo tuist; fi)

ifndef CI_JOB_ID
	XDG_CACHE_HOME ?= $(HOME)/.cache
else
	XDG_CACHE_HOME := /Users/macadmin/.tuist-cache/job-$(CI_JOB_ID)
endif

export XDG_CACHE_HOME

# Default target
project: run-sourcery tuist-setup tuist-generate
build: run-sourcery tuist-setup

# Run Tuist clean, install, and generate commands
tuist-setup:
	@echo "=== Running Tuist setup ==="
	@echo "📦 XDG_CACHE_HOME: $(XDG_CACHE_HOME)"
	@echo "📦 CI_JOB_ID: $(CI_JOB_ID)"
	@mkdir -p "$(XDG_CACHE_HOME)"
	@mkdir -p Tuist
	@if [ -d Tuist/.build ]; then \
		chmod -R u+w Tuist/.build 2>/dev/null || true; \
		for i in 1 2 3; do \
			rm -rf Tuist/.build 2>/dev/null || true; \
			[ ! -d Tuist/.build ] && break; \
			sleep 1; \
		done; \
		if [ -d Tuist/.build ]; then \
			echo "[WARN] Could not fully remove Tuist/.build, continuing..."; \
		fi; \
	fi
	@if ! $(TUIST_BIN) clean; then \
		echo "[WARN] Tuist clean failed. Continuing..."; \
	fi
	@if ! $(TUIST_BIN) install; then \
		echo "[WARN] Tuist install failed. Retrying once..."; \
		sleep 2; \
		if ! $(TUIST_BIN) install; then \
			echo "[WARN] Tuist install retry failed. Continuing with existing dependencies..."; \
		fi; \
	fi
	@echo "=== Tuist setup completed successfully ==="
	
# Run Tuist generate commands
tuist-generate:
	@echo "=== Running Tuist generate ==="
	@rm -rf Tuist/.build/tuist-derived/ModuleMaps 2>/dev/null || true
	@rm -rf Tuist/.build/tuist-derived 2>/dev/null || true
	@if ! $(TUIST_BIN) generate; then \
		echo "[WARN] Tuist generate failed. Retrying after cleanup..."; \
		rm -rf Tuist/.build/tuist-derived/ModuleMaps 2>/dev/null || true; \
		rm -rf Tuist/.build/tuist-derived 2>/dev/null || true; \
		$(TUIST_BIN) install || true; \
		if ! $(TUIST_BIN) generate; then \
			echo "[ERROR] Tuist generate failed after retry."; \
			exit 1; \
		fi; \
	fi
	@echo "=== Tuist generate completed successfully ==="

# Run Sourcery script
run-sourcery:
	@echo "Deleting all 'Generated' folders..."
	find . -type d -name "Generated" -exec rm -rf {} +

	@echo "Running Main queue Sourcery from root..."
	@if ! $(SOURCERY_MAIN_QUEUE_SCRIPT); then \
		echo "Sourcery failed. Exiting..."; \
		exit 1; \
	fi

	@echo "Running Weak proxy Sourcery from root..."
	@if ! $(SOURCERY_WEAK_PROXY_SCRIPT); then \
		echo "Sourcery failed. Exiting..."; \
		exit 1; \
	fi
	
	@echo "Running SwiftUI Adapter Sourcery from root..."
	@if ! $(SOURCERY_ADAPTER_SCRIPT); then \
		echo "Sourcery failed. Exiting..."; \
		exit 1; \
	fi
	@echo "Running Spy Generator Sourcery from root..."
	@if ! $(SOURCERY_SPY_SCRIPT); then \
		echo "Sourcery Spy Generator failed. Exiting..."; \
		exit 1; \
	fi
	@echo "Sourcery completed successfully."

# Release new tag incrementing its patch (e.g MAJOR.MINOR.PATCH.)
.PHONY: patch-tag

patch-tag:
	@git fetch --tags --force
	@LATEST_TAG=$(shell git ls-remote --tags origin | awk -F'/' '{print $$NF}' | grep '^3\.' | sort -V | tail -n 1) && \
	echo "Latest tag in series 3.x: $$LATEST_TAG" && \
	MAJOR=$$(echo $$LATEST_TAG | awk -F. '{print $$1}') && \
	MINOR=$$(echo $$LATEST_TAG | awk -F. '{print $$2}') && \
	PATCH=$$(echo $$LATEST_TAG | awk -F. '{print $$3+1}') && \
	NEW_TAG=$$MAJOR.$$MINOR.$$PATCH && \
	if git ls-remote --tags origin | grep -q "refs/tags/$$NEW_TAG"; then \
	    echo "Error: Tag $$NEW_TAG already exists. Increment manually if needed."; \
	    exit 1; \
	fi && \
	echo "Creating new tag: $$NEW_TAG" && \
	git tag $$NEW_TAG && \
	git push origin $$NEW_TAG
	
# Echo latest tag
.PHONY: show-latest-tag

show-latest-tag:
	@git fetch --tags --force
	@LATEST_TAG=$(shell git ls-remote --tags origin | awk -F'/' '{print $$NF}' | grep '^0\.' | sort -V | tail -n 1) && \
	echo "Latest tag in series 3.x: $$LATEST_TAG"
