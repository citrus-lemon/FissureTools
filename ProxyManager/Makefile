RUBY=ruby
.PHONY: build clean

build: SystemConfig/binding.bundle

SystemConfig/binding.bundle: SystemConfig/binding.m SystemConfig/type.m SystemConfig/type.h
	$(RUBY) -C SystemConfig extconf.rb
	$(MAKE) -C SystemConfig
	$(RM) -f SystemConfig/*.o SystemConfig/Makefile SystemConfig/constant.h

clean:
	$(RM) SystemConfig/binding.bundle