install:
	test ! -d ../scripts_original
	command mv ../scripts ../scripts_original
	command ln -s scripts ../scripts

remove:
	test -d ../scripts_original
	-command rm ../scripts
	command mv ../scripts_original ../scripts

.PHONY: install remove
