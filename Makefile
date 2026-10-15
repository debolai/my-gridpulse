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

