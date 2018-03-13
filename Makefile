# Its possible to make this more dynamic
# $(notdir $(shell dirname $(realpath $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))))
install:
	test ! -d ../scripts_original
	command mv ../scripts ../scripts_original
	command ln -s firefly/scripts ../scripts

remove:
	test -d ../scripts_original
	-command rm ../scripts
	command mv ../scripts_original ../scripts

.PHONY: install remove
