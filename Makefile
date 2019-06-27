.PHONY: test
test:
	vagrant up
	vagrant ssh -c /install.sh

