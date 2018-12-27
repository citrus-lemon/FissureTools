RUBY=ruby
.PHONY: build clean

build: DCSDictionary/binding.bundle

DCSDictionary/binding.bundle: DCSDictionary/binding.m
	$(RUBY) -C DCSDictionary extconf.rb
	$(MAKE) -C DCSDictionary
	$(RM) -f DCSDictionary/*.o DCSDictionary/Makefile

clean:
	$(RM) DCSDictionary/binding.bundle