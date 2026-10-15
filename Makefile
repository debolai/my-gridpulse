.DEFAULT_GOAL := help
SHELL := /bin/bash

help: ## List available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Install pinned dev tools and git hooks
	uv sync --locked
	uv run pre-commit install

lint: ## Run all linters (no changes made): Python, YAML, dbt SQL, Dockerfiles
	uv run ruff format --check .
	uv run ruff check .
	uv run yamllint --strict .

test: ## Run unit tests (no services needed)
	uv run pytest -q

# gitleaks reads text on stdin, so it never runs git inside the container (where git can fail
# and gitleaks would then report "no leaks" instead of an error).
GITLEAKS := docker run --rm -i -v "$(CURDIR)/.gitleaks.toml:/.gitleaks.toml:ro" \
	ghcr.io/gitleaks/gitleaks:v8.30.1@sha256:c00b6bd0aeb3071cbcb79009cb16a60dd9e0a7c60e2be9ab65d25e6bc8abbb7f \
	stdin --config /.gitleaks.toml --redact --no-banner --verbose

secrets-staged: ## Scan staged changes for API keys and other secrets (pre-commit hook)
	@set -o pipefail; git diff --cached --no-color | $(GITLEAKS)

secrets-history: ## Scan every commit for API keys and other secrets (CI)
	@set -o pipefail; git log --all -p --no-color | $(GITLEAKS)

