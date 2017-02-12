.PHONY: test
test: autoversion venv
	venv/bin/pre-commit run --all-files
	venv/bin/pre-commit install -f --install-hooks

.PHONY: builddeb
builddeb: autoversion
	dpkg-buildpackage -us -uc

.PHONY: package
package: package_jessie package_stretch

.PHONY: package_%
package_%: dist
	cp debian/links.$* debian/links
	docker run -e "DIST_UID=$(shell id -u)" -e "DIST_GID=$(shell id -g)" -v $(CURDIR):/mnt:rw "docker.ocf.berkeley.edu/theocf/debian:$*" /mnt/build-in-docker "$*"

dist:
	mkdir -p "$@"

.PHONY: autoversion
autoversion:
	date +%Y.%m.%d.%H.%M-git`git rev-list -n1 HEAD | cut -b1-8` > .version
	rm -f debian/changelog
	DEBFULLNAME="Open Computing Facility" DEBEMAIL="help@ocf.berkeley.edu" VISUAL=true \
		dch -v `sed s/-/+/g .version` -D stable --no-force-save-on-release \
		--create --package "ocf-approve" "Package for Debian."

venv: autoversion vendor/venv-update requirements.txt requirements-dev.txt setup.py
	vendor/venv-update \
		venv= -ppython3 venv \
		install= -r requirements.txt -r requirements-dev.txt -e .

.PHONY: clean
clean:
	rm -rf debian/*.debhelper debian/*.log

.PHONY: update-requirements
update-requirements: venv
	venv/bin/upgrade-requirements
	sed -i 's/^ocflib==.*/ocflib/' requirements.txt
