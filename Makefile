SOURCERY_MAIN_QUEUE_SCRIPT=./Scripts/Sourcery/MainQueueDispatchDecorator.sh
SOURCERY_WEAK_PROXY_SCRIPT=./Scripts/Sourcery/WeakRefVirtualProxy.sh
SOURCERY_ADAPTER_SCRIPT=./Scripts/Sourcery/SwiftUIAdapterGenerator.sh
TUIST_COMMANDS="tuist clean; tuist install; tuist generate"

# Default target
project: run-sourcery tuist-setup
build: run-sourcery tuist-generate

# Run Tuist clean, install, and generate commands
tuist-setup:
	@echo "Running Tuist setup..."
	@if ! tuist clean; then \
		echo "Tuist clean failed. Ensure Tuist is installed and properly configured."; \
		exit 1; \
	fi
	@if ! tuist install; then \
		echo "Tuist install failed. Check if you have the correct environment for your project."; \
		exit 1; \
	fi
	@if ! tuist generate; then \
		echo "Tuist generate failed. Ensure your project configuration is valid."; \
		exit 1; \
	fi
	@echo "Tuist setup completed successfully."
	
# Run Tuist generate commands
tuist-generate:
	@echo "Running Tuist generate..."
	@if ! tuist generate; then \
		echo "Tuist generate failed. Ensure your project configuration is valid."; \
		exit 1; \
	fi
	@echo "Tuist generate completed successfully."

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
