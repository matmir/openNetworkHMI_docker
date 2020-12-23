openNetworkHMI docker
=======

Script creates 2 images:<br />
onh-base - image with debian based system with all required dependencies for openNetworkHMI project<br />
onh-clean - image with clean installation of the openNetworkHMI project

INSTALLATION
============

	git clone https://github.com/matmir/openNetworkHMI_docker.git

USAGE
=====

	./createOnhImage.sh baseImageTag cleanImageTag CommitComment CommitUser [branchName] [askMode] [buildTest]

	baseImageTag  - onh-base image tag.
	cleanImageTag - onh-clean image tag.
	CommitComment - Comment for image commit.
	CommitUser    - Username for image commit.
	branchName    - Project branch to install.
	                Values: valid git branch names - default "master".
    askMode       - install with additional user questions.
                    Values: "ask" or "askOFF" - default "askOFF".
    buildTest     - compile tests.
                    Values: "test" or "testOFF" - default "testOFF".

Install develop version with ask mode and tests:

	./createOnhImage.sh 0.1 0.5 "Create onh image" "Mateusz" develop ask test

Start the container:

	docker run -d --name onh-test -p 8085:80 --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro onh-clean:0.5

OTHER
=====

	Debian user/pass:  onh/onh
	MariaDB user/pass: admin/admin

Project site: https://opennetworkhmi.net

License
=======

Software is licensed on GPLv3 license.
