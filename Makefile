SOURCERY_SCRIPT=./Scripts/Sourcery/MainQueueDispatchDecorator.sh
OPEN_COMMAND = "open package.swift"

# Default target
project: run-sourcery open-command

# Run Open command
open-command:
	@echo "Opening Package.swift..."
	@if ! open package.swift; then \
		echo "Openin Package.swift failed. Ensure is Package.swift file is created"; \
		exit 1; \
	fi
	@echo "Opening successfully"

# Run Sourcery script
run-sourcery:
	@echo "Running Sourcery from root..."
	@if ! $(SOURCERY_SCRIPT); then \
		echo "Sourcery failed. Exiting..."; \
		exit 1; \
	fi
	@echo "Sourcery completed successfully."
