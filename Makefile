# Makefile for building 'mgba' RPMs from a local project directory
# Created on: Fri 05 Dec 2025
# Created by: gopeterjun@naver.com
# Last Updated: Fri 05 Dec 2025

# Define the RPM build directories
BUILD_DIRS = SPECS SOURCES BUILD RPMS SRPMS BUILDROOT

# Define required tools to build RPM packages
REQUIRED_BINS := rpmbuild rpmspec spectool

# Define the location of the spec file
SPEC_FILE = SPECS/mgba.spec
UPSTREAM_REPO = mgba-emu/mgba

# Get the absolute path to the current directory
TOP_DIR = $(shell pwd)
TMP_DIR = $(TOP_DIR)/tmp

# Phony targets aren't actual files
.PHONY: all help scaffold test latest-upstream-tag latest-upstream-version check-upstream-version sources srpm build clean

# Default target: build the RPM
all: build

test: check-tools
	@echo "✓  All RPM build tools are available."

check-tools:
	@echo "Checking for RPM build tools..."
	@for bin in $(REQUIRED_BINS); do \
		type $$bin >/dev/null || { echo "ERROR: $$bin not found in PATH"; exit 1; }; \
	done
	@echo "All required binaries found: $(REQUIRED_BINS)"

# The scaffold target creates the directory structure
scaffold:
	@echo "Creating RPM build directory structure..."
	@mkdir -p $(BUILD_DIRS)
	@echo "Done."

# Print the latest upstream GitHub release tag. Prefer gh when available, fall back to curl.
latest-upstream-tag:
	@if command -v gh >/dev/null 2>&1 \
		&& tag=$$(gh release view --repo $(UPSTREAM_REPO) --json tagName --jq .tagName 2>/dev/null) \
		&& [ -n "$$tag" ]; then \
		printf '%s\n' "$$tag"; \
	else \
		curl -fsSL https://api.github.com/repos/$(UPSTREAM_REPO)/releases/latest \
			| python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])'; \
	fi

# Print the RPM Version value encoded by the latest upstream release tag.
latest-upstream-version:
	@$(MAKE) --no-print-directory latest-upstream-tag | sed 's/^v//'

# Ensure the RPM Version matches the latest upstream release tag before building.
check-upstream-version:
	@upstream_tag=$$($(MAKE) --no-print-directory latest-upstream-tag); \
	upstream_version=$$(printf '%s\n' "$$upstream_tag" | sed 's/^v//'); \
	spec_version=$$(rpmspec -q --qf '%{VERSION}\n' $(SPEC_FILE) | head -n1); \
	if [ "$$spec_version" != "$$upstream_version" ]; then \
		echo "ERROR: $(SPEC_FILE) Version is $$spec_version, but upstream $(UPSTREAM_REPO) latest release tag is $$upstream_tag (RPM Version $$upstream_version)." >&2; \
		echo "Update the spec Version/%%changelog before building for COPR." >&2; \
		exit 1; \
	fi; \
	echo "$(SPEC_FILE) Version $$spec_version matches upstream $(UPSTREAM_REPO) release tag $$upstream_tag."

# The 'sources' target downloads sources locally
sources: scaffold test check-upstream-version
	@echo "Downloading sources to $(TOP_DIR)/SOURCES..."
	@spectool -g -R --define "_topdir $(TOP_DIR)" $(SPEC_FILE)

# The 'srpm' target builds only the source RPM, suitable for COPR upload.
srpm: sources
	@echo "Building source RPM in $(TOP_DIR)..."
	@mkdir -p $(TMP_DIR)
	@rpmbuild -bs --define "_topdir $(TOP_DIR)" --define "_tmppath $(TMP_DIR)" $(SPEC_FILE)
	@echo "Source RPM complete. Find SRPMs in $(TOP_DIR)/SRPMS."

# The 'build' target builds the binary and source RPMs
build: sources
	@echo "Building RPMs in $(TOP_DIR)..."
	@mkdir -p $(TMP_DIR)
	@rpmbuild -ba --define "_topdir $(TOP_DIR)" --define "_tmppath $(TMP_DIR)" $(SPEC_FILE)
	@echo "Build complete. Find RPMs in $(TOP_DIR)/RPMS and $(TOP_DIR)/SRPMS."

# The 'clean' target removes build outputs
clean:
	@echo "Cleaning build directories..."
	@rm -rf BUILD BUILDROOT RPMS SRPMS
	@echo "Done."

# The help target explains available commands
help:
	@echo "  make test      - check for 'rpmbuild' dependencies."
	@echo "  make scaffold  - Creates the standard RPM build directories."
	@echo "  make latest-upstream-tag     - Prints the latest upstream GitHub release tag."
	@echo "  make latest-upstream-version - Prints the RPM Version from the latest upstream tag."
	@echo "  make check-upstream-version  - Verifies the spec Version matches upstream."
	@echo "  make sources   - Downloads source tarballs into the local SOURCES directory."
	@echo "  make srpm      - Builds only the source RPM for COPR upload."
	@echo "  make build     - Builds the binary and source RPMs (default)."
	@echo "  make clean     - Removes the BUILD, BUILDROOT, RPMS, and SRPMS directories."
