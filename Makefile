SOURCERY_SCRIPT=./Scripts/Sourcery/MainQueueDispatchDecorator.sh
GENERATED_DIR=./Generated
OPEN_COMMAND="open Package.swift"


# Default target
project: clean-sourcery run-sourcery open-command

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
