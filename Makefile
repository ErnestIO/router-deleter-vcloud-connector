default: deps

lint:
	rubocop --fail-fast

cover:
	COVERAGE=true MIN_COVERAGE=50 bundle exec rspec -c -f d spec

test:
	bundle exec rspec -f d spec

deps:
	bundle install

clean:
	rm -rf coverage
