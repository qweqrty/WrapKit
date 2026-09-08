SOURCERY_MAIN_QUEUE_SCRIPT=./Scripts/Sourcery/MainQueueDispatchDecorator.sh
SOURCERY_WEAK_PROXY_SCRIPT=./Scripts/Sourcery/WeakRefVirtualProxy.sh
SOURCERY_ADAPTER_SCRIPT=./Scripts/Sourcery/SwiftUIAdapterGenerator.sh
SOURCERY_SPY_SCRIPT=./Scripts/Sourcery/SpyGenerator.sh
UPDATE_PACKAGE_LOCKS_SCRIPT=./Scripts/update-tuist-package-locks.sh
TUIST_COMMANDS="tuist install (Registry -> Git fallback); tuist generate"
TUIST_USE_REGISTRY ?= 1
TUIST_REGISTRY_ARGUMENTS := --replace-scm-with-registry --force-resolved-versions
TUIST_REGISTRY_RESOLVED := Tuist/Package.registry.resolved
TUIST_DOWNLOAD_VERSION := 4.203.1
TUIST_DOWNLOAD_SHA256 := 7af01272af69a460729f82de71d68cd34a35bb3b21622cfd12c0c7b74e1a1b3b
PACKAGE_LOCKS_MODE ?= update

WRAPKIT_CACHE_HOME ?= $(HOME)/Library/Caches/WrapKit
TUIST_DOWNLOAD_DIRECTORY := $(WRAPKIT_CACHE_HOME)/tuist/$(TUIST_DOWNLOAD_VERSION)
TUIST_DOWNLOAD_BIN := $(TUIST_DOWNLOAD_DIRECTORY)/tuist
TUIST_INSTALLED_BIN := $(shell \
	which -a tuist 2>/dev/null | awk '!seen[$$0]++' | while IFS= read -r candidate; do \
		resolved_candidate="$$candidate"; \
		if [ -L "$$candidate" ]; then \
			link_target=$$(readlink "$$candidate" 2>/dev/null || true); \
			if printf '%s' "$$link_target" | grep -q '^/'; then \
				resolved_candidate="$$link_target"; \
			else \
				resolved_candidate="$$(dirname "$$candidate")/$$link_target"; \
			fi; \
		fi; \
		candidate_directory=$$(CDPATH= cd "$$(dirname "$$resolved_candidate")" 2>/dev/null && pwd -P); \
		script_prefix=$$(head -c 2 "$$resolved_candidate" 2>/dev/null | od -An -tx1 | tr -d ' '); \
		is_full_distribution=0; \
		is_tool_manager_shim=0; \
		if printf '%s' "$$candidate" | grep -q '/shims/'; then \
			is_tool_manager_shim=1; \
		fi; \
		if [ -n "$$candidate_directory" ] \
			&& { [ -d "$$candidate_directory/ProjectDescription.framework" ] \
				|| [ "$$script_prefix" = '2321' ] \
				|| [ "$$is_tool_manager_shim" -eq 1 ]; }; then \
			is_full_distribution=1; \
		fi; \
		if [ "$$is_full_distribution" -eq 1 ] && "$$candidate" version >/dev/null 2>&1; then \
			printf '%s' "$$candidate"; \
			break; \
		fi; \
	done)
ifneq ($(strip $(TUIST_INSTALLED_BIN)),)
	TUIST_BIN ?= $(TUIST_INSTALLED_BIN)
else
	TUIST_BIN ?= $(TUIST_DOWNLOAD_BIN)
endif

# Default target
.NOTPARALLEL:
project: package-locks tuist-check run-sourcery tuist-setup tuist-generate
build: package-locks tuist-check run-sourcery tuist-setup

.PHONY: project build ci-project package-locks update-package-locks tuist-download tuist-check tuist-install tuist-setup tuist-generate

ci-project: tuist-download
	@$(MAKE) --no-print-directory \
		PACKAGE_LOCKS_MODE=verify \
		TUIST_BIN="$(TUIST_DOWNLOAD_BIN)" \
		project

package-locks:
	@if [ "$(PACKAGE_LOCKS_MODE)" = "verify" ]; then \
		$(UPDATE_PACKAGE_LOCKS_SCRIPT) --verify "$(TUIST_DOWNLOAD_VERSION)"; \
		exit $$?; \
	fi; \
	status=0; \
	$(UPDATE_PACKAGE_LOCKS_SCRIPT) --status "$(TUIST_DOWNLOAD_VERSION)" || status=$$?; \
	if [ "$$status" -eq 0 ]; then \
		exit 0; \
	fi; \
	if [ "$$status" -ne 3 ]; then \
		exit "$$status"; \
	fi; \
	lock_tuist="$(TUIST_BIN)"; \
	lock_tuist_version="$$("$$lock_tuist" version 2>/dev/null | awk 'NR == 1 { print $$1 }' || true)"; \
	if [ "$$lock_tuist_version" != "$(TUIST_DOWNLOAD_VERSION)" ]; then \
		if [ -n "$$lock_tuist_version" ]; then \
			if ! ./Scripts/ensure-tuist.sh \
				--yes \
				"$(TUIST_DOWNLOAD_VERSION)" \
				"$(TUIST_DOWNLOAD_SHA256)" \
				"$(TUIST_DOWNLOAD_DIRECTORY)"; then \
				exit 1; \
			fi; \
		elif ! ./Scripts/ensure-tuist.sh \
			"$(TUIST_DOWNLOAD_VERSION)" \
			"$(TUIST_DOWNLOAD_SHA256)" \
			"$(TUIST_DOWNLOAD_DIRECTORY)"; then \
			exit 1; \
		fi; \
		lock_tuist="$(TUIST_DOWNLOAD_BIN)"; \
	fi; \
	echo "=== Updating Tuist package locks automatically ==="; \
	$(UPDATE_PACKAGE_LOCKS_SCRIPT) "$$lock_tuist"

update-package-locks: tuist-download
	@$(UPDATE_PACKAGE_LOCKS_SCRIPT) "$(TUIST_DOWNLOAD_BIN)"

tuist-download:
	@./Scripts/ensure-tuist.sh \
		--yes \
		"$(TUIST_DOWNLOAD_VERSION)" \
		"$(TUIST_DOWNLOAD_SHA256)" \
		"$(TUIST_DOWNLOAD_DIRECTORY)"

tuist-check:
	@if [ "$(TUIST_BIN)" = "$(TUIST_DOWNLOAD_BIN)" ]; then \
		./Scripts/ensure-tuist.sh \
			"$(TUIST_DOWNLOAD_VERSION)" \
			"$(TUIST_DOWNLOAD_SHA256)" \
			"$(TUIST_DOWNLOAD_DIRECTORY)"; \
	elif ! command -v "$(TUIST_BIN)" >/dev/null 2>&1; then \
		echo "[ERROR] Tuist was not found at $(TUIST_BIN)."; \
		exit 1; \
	fi
	@installed_version="$$("$(TUIST_BIN)" version 2>/dev/null | awk 'NR == 1 { print $$1 }')"; \
	if [ -z "$$installed_version" ]; then \
		echo "[ERROR] Tuist was not found. Install it with Homebrew, mise, or another supported method."; \
		exit 1; \
	fi; \
	echo "=== Using Tuist $$installed_version ($(TUIST_BIN)) ==="

tuist-install: tuist-check
	@start_time=$$(date +%s); \
	installed_version="$$("$(TUIST_BIN)" version 2>/dev/null | awk 'NR == 1 { print $$1 }')"; \
	registry_supported=0; \
	git_passthrough_supported=0; \
	tuist_install_help="$$("$(TUIST_BIN)" help install 2>/dev/null || true)"; \
	swift_package_help="$$(xcrun swift package --help 2>/dev/null || true)"; \
	if [ "$(TUIST_USE_REGISTRY)" = "1" ] \
		&& printf '%s' "$$tuist_install_help" | grep -q 'passthrough-arguments' \
		&& printf '%s' "$$swift_package_help" | grep -q -- '--replace-scm-with-registry' \
		&& printf '%s' "$$swift_package_help" | grep -q -- '--force-resolved-versions'; then \
		registry_supported=1; \
	fi; \
	if printf '%s' "$$tuist_install_help" | grep -q 'passthrough-arguments' \
		&& printf '%s' "$$swift_package_help" | grep -q -- '--disable-scm-to-registry-transformation' \
		&& printf '%s' "$$swift_package_help" | grep -q -- '--force-resolved-versions'; then \
		git_passthrough_supported=1; \
	fi; \
	package_resolved_lock_key=$$(printf '%s' "$$(pwd -P)" | shasum -a 256 | awk '{ print $$1 }'); \
	package_resolved_lock_root="$${TMPDIR:-/tmp}"; \
	package_resolved_lock="$${package_resolved_lock_root%/}/wrapkit-package-locks-$$package_resolved_lock_key.lock"; \
	exec 9>"$$package_resolved_lock"; \
	if ! /usr/bin/lockf -s -t 180 9; then \
		echo "[ERROR] Timed out waiting to install Tuist dependencies. Retry later."; \
		exit 1; \
	fi; \
	resolved_backup=$$(mktemp -t wrapkit-package-resolved) || { echo "[ERROR] Could not create Package.resolved backup."; exit 1; }; \
	if ! cp Tuist/Package.resolved "$$resolved_backup"; then \
		rm -f "$$resolved_backup"; \
		echo "[ERROR] Could not back up Package.resolved."; \
		exit 1; \
	fi; \
	install_mode_file="Tuist/.build/.wrapkit-install-mode"; \
	install_version_file="Tuist/.build/.wrapkit-tuist-version"; \
	install_lock_file="Tuist/.build/.wrapkit-lock-sha256"; \
	scm_lock_hash=$$(shasum -a 256 "$$resolved_backup" | awk '{ print $$1 }'); \
	registry_lock_hash=$$(shasum -a 256 "$(TUIST_REGISTRY_RESOLVED)" | awk '{ print $$1 }'); \
	remove_build_directory() { \
		if [ ! -e Tuist/.build ]; then \
			return 0; \
		fi; \
		chmod -R u+w Tuist/.build 2>/dev/null || true; \
		attempt=0; \
		while [ "$$attempt" -lt 3 ]; do \
			rm -rf Tuist/.build 2>/dev/null || true; \
			if [ ! -e Tuist/.build ]; then \
				return 0; \
			fi; \
			sleep 1; \
			attempt=$$((attempt + 1)); \
		done; \
		return 1; \
	}; \
	restore_resolved() { \
		if ! cp "$$resolved_backup" Tuist/Package.resolved; then \
			echo "[ERROR] Could not restore the committed Package.resolved."; \
			return 1; \
		fi; \
		rm -f "$$resolved_backup"; \
	}; \
	prepare_build_for_mode() { \
		requested_mode="$$1"; \
		requested_lock_hash="$$2"; \
		current_mode=$$(cat "$$install_mode_file" 2>/dev/null || true); \
		current_version=$$(cat "$$install_version_file" 2>/dev/null || true); \
		current_lock_hash=$$(cat "$$install_lock_file" 2>/dev/null || true); \
		if [ "$$current_mode" != "$$requested_mode" ] \
			|| [ "$$current_version" != "$$installed_version" ] \
			|| [ "$$current_lock_hash" != "$$requested_lock_hash" ]; then \
			remove_build_directory || return 1; \
		fi; \
		mkdir -p Tuist/.build || return 1; \
		rm -f "$$install_mode_file"; \
		rm -f "$$install_version_file"; \
		rm -f "$$install_lock_file"; \
	}; \
	prepare_git_install() { \
		cp "$$resolved_backup" Tuist/Package.resolved || return 1; \
		prepare_build_for_mode git "$$scm_lock_hash" || return 1; \
	}; \
	install_from_git() { \
		prepare_git_install || return 1; \
		if [ "$$git_passthrough_supported" = "1" ]; then \
			"$(TUIST_BIN)" install --disable-scm-to-registry-transformation --force-resolved-versions; \
		else \
			"$(TUIST_BIN)" install; \
		fi; \
	}; \
	clear_ci_swiftpm_cache() { \
		if [ -z "$${RUNNER_TEMP:-}" ] || [ -z "$${XDG_CACHE_HOME:-}" ]; then \
			return 0; \
		fi; \
		case "$$XDG_CACHE_HOME" in \
			"$$RUNNER_TEMP"|"$$RUNNER_TEMP"/*) \
				rm -rf "$$XDG_CACHE_HOME/swifterpm" 2>/dev/null || return 1; \
				;; \
		esac; \
	}; \
	trap 'restore_resolved || exit 1' EXIT; \
	mode="git"; \
	cache_mode="git"; \
	selected_lock_hash="$$scm_lock_hash"; \
	if [ "$(TUIST_USE_REGISTRY)" = "1" ] && [ "$$registry_supported" = "1" ]; then \
		mode="registry"; \
		cache_mode="registry"; \
		selected_lock_hash="$$registry_lock_hash"; \
		echo "=== Resolving SwiftPM dependencies through Tuist Registry ==="; \
		if ! prepare_build_for_mode registry "$$registry_lock_hash"; then \
			echo "[ERROR] Could not prepare the Registry dependency cache."; \
			exit 1; \
		elif ! cp "$(TUIST_REGISTRY_RESOLVED)" Tuist/Package.resolved; then \
			echo "[ERROR] Could not prepare the Registry Package.resolved."; \
			exit 1; \
		elif ! "$(TUIST_BIN)" install $(TUIST_REGISTRY_ARGUMENTS); then \
			mode="git-fallback"; \
			cache_mode="git"; \
			selected_lock_hash="$$scm_lock_hash"; \
			echo "[WARN] Registry install failed. Falling back to Git..."; \
			if ! clear_ci_swiftpm_cache; then \
				echo "[WARN] Could not clear the CI SwiftPM cache before Git fallback."; \
			fi; \
			if ! install_from_git; then \
				echo "[ERROR] Both Registry and Git dependency installs failed."; \
				exit 1; \
			fi; \
		fi; \
	else \
		if [ "$(TUIST_USE_REGISTRY)" = "1" ]; then \
			echo "[INFO] Tuist $$installed_version does not support the required Registry arguments. Using Git dependency resolution."; \
		fi; \
		echo "=== Resolving SwiftPM dependencies through Git ==="; \
		if ! install_from_git; then \
			echo "[ERROR] Git dependency install failed."; \
			exit 1; \
		fi; \
	fi; \
	resolution_state="Tuist/.build/swifterpm/package-info/index.json"; \
	if [ -f "$$resolution_state" ]; then \
		registry_packages=$$(grep -c '"kind"[[:space:]]*:[[:space:]]*"registry"' "$$resolution_state" 2>/dev/null || true); \
		git_packages=$$(grep -c '"kind"[[:space:]]*:[[:space:]]*"remoteSourceControl"' "$$resolution_state" 2>/dev/null || true); \
	elif [ -d Tuist/.build/checkouts ] || [ -d Tuist/.build/registry/downloads ]; then \
		registry_packages=$$(find Tuist/.build/registry/downloads -mindepth 3 -maxdepth 3 -type d 2>/dev/null | wc -l | tr -d ' '); \
		git_packages=$$(find Tuist/.build/checkouts -mindepth 1 -maxdepth 1 \( -type d -o -type l \) 2>/dev/null | wc -l | tr -d ' '); \
	else \
		resolution_state="Tuist/Package.resolved"; \
		registry_packages=$$(grep -c '"kind"[[:space:]]*:[[:space:]]*"registry"' "$$resolution_state" 2>/dev/null || true); \
		git_packages=$$(grep -c '"kind"[[:space:]]*:[[:space:]]*"remoteSourceControl"' "$$resolution_state" 2>/dev/null || true); \
	fi; \
	known_packages=$$((registry_packages + git_packages)); \
	if [ "$$mode" = "registry" ]; then \
		if [ "$$known_packages" -eq 0 ]; then \
			mode="registry-unverified"; \
			cache_mode="git"; \
			echo "[WARN] Could not verify the dependency transport. The build will continue without publishing this cache."; \
		elif [ "$$registry_packages" -gt 0 ] && [ "$$git_packages" -gt 0 ]; then \
			mode="registry-with-git"; \
		elif [ "$$registry_packages" -eq 0 ]; then \
			mode="git-fallback"; \
			cache_mode="git"; \
			selected_lock_hash="$$scm_lock_hash"; \
		fi; \
	fi; \
	if ! cp Tuist/Package.resolved Tuist/.build/Package.install.resolved; then \
		echo "[ERROR] Could not preserve the resolved dependencies for generation."; \
		exit 1; \
	fi; \
	if ! printf '%s\n' "$$cache_mode" > "$$install_mode_file"; then \
		echo "[ERROR] Could not mark the dependency cache mode."; \
		exit 1; \
	fi; \
	if ! printf '%s\n' "$$installed_version" > "$$install_version_file"; then \
		echo "[ERROR] Could not mark the Tuist cache version."; \
		exit 1; \
	fi; \
	if ! printf '%s\n' "$$selected_lock_hash" > "$$install_lock_file"; then \
		echo "[ERROR] Could not mark the resolved dependency state."; \
		exit 1; \
	fi; \
	elapsed=$$(($$(date +%s) - start_time)); \
	size_kb=$$(du -sk Tuist/.build 2>/dev/null | awk '{print $$1}'); \
	echo "=== Tuist install mode: $$mode; Registry packages: $${registry_packages:-0}; Git packages: $${git_packages:-0}; duration: $${elapsed}s; dependency data: $${size_kb:-0} KB ==="

# Install dependencies and generate the project
tuist-setup: tuist-check
	@echo "=== Running Tuist setup ==="
	@echo "📦 SwiftPM cache: $${XDG_CACHE_HOME:-system default}"
	@if [ -n "$${XDG_CACHE_HOME:-}" ]; then mkdir -p "$$XDG_CACHE_HOME"; fi
	@mkdir -p Tuist
	@if [ -d Tuist/.build ]; then chmod -R u+w Tuist/.build 2>/dev/null || true; fi
	@$(MAKE) --no-print-directory tuist-install
	@echo "=== Tuist setup completed successfully ==="
	
# Run Tuist generate commands
tuist-generate: tuist-check
	@echo "=== Running Tuist generate ==="
	@rm -rf Tuist/.build/tuist-derived/ModuleMaps 2>/dev/null || true
	@rm -rf Tuist/.build/tuist-derived 2>/dev/null || true
	@install_resolved="Tuist/.build/Package.install.resolved"; \
	resolved_backup=""; \
	package_resolved_lock_key=$$(printf '%s' "$$(pwd -P)" | shasum -a 256 | awk '{ print $$1 }'); \
	package_resolved_lock_root="$${TMPDIR:-/tmp}"; \
	package_resolved_lock="$${package_resolved_lock_root%/}/wrapkit-package-locks-$$package_resolved_lock_key.lock"; \
	acquire_package_resolved_lock() { \
		exec 9>"$$package_resolved_lock"; \
		/usr/bin/lockf -s -t 180 9; \
	}; \
	release_package_resolved_lock() { \
		exec 9>&-; \
	}; \
	use_install_resolved_if_needed() { \
		if [ -f "$$install_resolved" ]; then \
			candidate_backup=$$(mktemp -t wrapkit-package-resolved) || return 1; \
			if ! cp Tuist/Package.resolved "$$candidate_backup"; then \
				rm -f "$$candidate_backup"; \
				return 1; \
			fi; \
			resolved_backup="$$candidate_backup"; \
			cp "$$install_resolved" Tuist/Package.resolved || return 1; \
		fi; \
	}; \
	restore_resolved() { \
		if [ -n "$$resolved_backup" ] && [ -f "$$resolved_backup" ]; then \
			if ! cp "$$resolved_backup" Tuist/Package.resolved; then \
				echo "[ERROR] Could not restore the committed Package.resolved."; \
				return 1; \
			fi; \
			rm -f "$$resolved_backup"; \
			resolved_backup=""; \
		fi; \
		rm -f "$$install_resolved"; \
	}; \
	trap 'restore_resolved || exit 1' EXIT; \
	if ! acquire_package_resolved_lock; then \
		echo "[ERROR] Timed out waiting to generate the Tuist project. Retry later."; \
		exit 1; \
	fi; \
	if ! use_install_resolved_if_needed; then \
		echo "[ERROR] Could not prepare Package.resolved for generation."; \
		exit 1; \
	fi; \
	if ! "$(TUIST_BIN)" generate; then \
		echo "[WARN] Tuist generate failed. Retrying after cleanup..."; \
		if ! restore_resolved; then \
			exit 1; \
		fi; \
		release_package_resolved_lock; \
		cleared_ci_cache=0; \
		if [ -n "$${RUNNER_TEMP:-}" ] && [ -n "$${XDG_CACHE_HOME:-}" ]; then \
			case "$$XDG_CACHE_HOME" in \
				"$$RUNNER_TEMP"|"$$RUNNER_TEMP"/*) \
					chmod -R u+w Tuist/.build "$$XDG_CACHE_HOME/swifterpm" 2>/dev/null || true; \
					rm -rf Tuist/.build "$$XDG_CACHE_HOME/swifterpm" 2>/dev/null || true; \
					cleared_ci_cache=1; \
					echo "[WARN] Retrying with a cold CI dependency cache."; \
					;; \
			esac; \
		fi; \
		if [ "$$cleared_ci_cache" -ne 1 ]; then \
			rm -rf Tuist/.build/tuist-derived/ModuleMaps 2>/dev/null || true; \
			rm -rf Tuist/.build/tuist-derived 2>/dev/null || true; \
		fi; \
		if ! $(MAKE) --no-print-directory tuist-install; then \
			echo "[ERROR] Tuist install failed during generate retry."; \
			exit 1; \
		fi; \
		if ! acquire_package_resolved_lock; then \
			echo "[ERROR] Timed out waiting to retry Tuist generation."; \
			exit 1; \
		fi; \
		if ! use_install_resolved_if_needed; then \
			echo "[ERROR] Could not prepare Package.resolved for generate retry."; \
			exit 1; \
		fi; \
		if ! "$(TUIST_BIN)" generate; then \
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
