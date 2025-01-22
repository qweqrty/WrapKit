SOURCERY_SCRIPT=./Scripts/Sourcery/MainQueueDispatchDecorator.sh
GENERATED_DIR=./Generated
OPEN_COMMAND="open Package.swift"

# Default target
project: clean-sourcery run-sourcery open-command

# Push new tag incrementing its patch (e.g MAJOR.MINOR.PATCH.)
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
	@LATEST_TAG=$(shell git ls-remote --tags origin | awk -F'/' '{print $$NF}' | grep '^3\.' | sort -V | tail -n 1) && \
	echo "Latest tag in series 3.x: $$LATEST_TAG"

# Open the Package.swift file
open-command:
	@echo "Opening Package.swift..."
	@if ! open package.swift; then \
		echo "Openin Package.swift failed. Ensure is Package.swift file is created"; \
		exit 1; \
	fi
	@echo "Opening successfully"

# Clean all Sourcery-generated files
clean-sourcery:
	@echo "Cleaning Sourcery-generated files..."
	@if [ -d $(GENERATED_DIR) ]; then \
		find $(GENERATED_DIR) -type f -name '*Output*' -delete; \
		echo "Cleaned all files matching '*Output*' in $(GENERATED_DIR)."; \
	else \
		echo "$(GENERATED_DIR) does not exist. Creating directory."; \
		mkdir -p $(GENERATED_DIR); \
	fi


# Run Sourcery script to regenerate files
run-sourcery:
	@echo "Running Sourcery to regenerate files..."
	@if ! $(SOURCERY_SCRIPT); then \
		echo "Sourcery failed. Please check the script at $(SOURCERY_SCRIPT). Exiting..."; \
		exit 1; \
	fi
	@echo "Sourcery completed successfully. All files regenerated."

# Help target
help:
	@echo "Available targets:"
	@echo "  project          - Clean, regenerate Sourcery files, and open Package.swift."
	@echo "  open-command     - Open Package.swift."
	@echo "  clean-sourcery   - Clean all Sourcery-generated files matching '*Output*'."
	@echo "  run-sourcery     - Regenerate Sourcery files using the script."
