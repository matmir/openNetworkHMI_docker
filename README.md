openNetworkHMI docker
=======

Script creates 2 images:
onh-base - image with debian based system with all required dependencies for openNetworkHMI project
onh-clean - image with clean installation of the openNetworkHMI project

INSTALLATION
============

git clone https://github.com/matmir/openNetworkHMI_docker.git

USAGE
=====
./createOnhImage.sh baseImageTag cleanImageTag CommitComment CommitUser

Example:
./createOnhImage.sh 0.1 0.5 "Create onh image" "Mateusz"

Start the container:
docker run -d --name onh-test -p 8085:80 --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro onh-clean:0.5

OTHER
=====
Debian user/pass: onh/onh
MariaDB user/pass: admin/admin

Project site: https://opennetworkhmi.net

License
=======

Software is licensed on GPLv3 license.