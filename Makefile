APP_ENTRY=html/index.html
PATH := $(PATH):node_modules/.bin

prettier := prettier $options --ignore-path .gitignore '**/*.+(json|ts|html)'
elm-format := elm-format $options --elm-version=0.19 elm/src elm/tests


# Production build
build:
	parcel build $(APP_ENTRY)

# Install dependencies
install:
	npm install

# Hot reloading development
dev:
	parcel $(APP_ENTRY)

# Serve module docs
docs:
	cd elm; \
	elm-doc-preview --no-browser;

# Run the test suite
test:
	cd elm; \
        elm-verify-examples; \
# elm-format --yes tests/VerifyExamples; \
# elm-test

# Run the test suite in watch mode
test-watch:
	watch 'make test' elm/src elm/tests/Tests

# Generate typescript types from elm ports
gen-ts:
	elm-typescript-interop

# Format code
format:
	$(elm-format:$options=--yes)
	$(prettier:$options=--write)

# Checks if code is formatted correctly
check-format:
	$(elm-format:$options=--validate)
	$(prettier:$options=--check)

# Clean dependency directories
clean:
	rm -rf node_modules
	rm -rf elm/elm-stuff

# Generate Nix expressions for CI and deployment
gen-nix: clean
        # Unfortunately this hack is needed
	bash sh/node2nix.sh

        # Unfortunately `elm2nix` is not yet distributed via NPM
	cd elm; \
	elm2nix convert > elm-srcs.nix; \
	elm2nix snapshot > versions.dat; \
	mv elm-srcs.nix versions.dat --target ../nix/elm2nix

# Product build using Nix
build-nix:
	nix-build nix

# Checks format and tests
check: check-format test
