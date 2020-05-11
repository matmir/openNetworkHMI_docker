#!/bin/bash

# Check arguments
if [ $# -ne 4 ]
then
	echo "Usage: ./createOnhImage.sh baseImageTag cleanImageTag CommitComment CommitUser"
	exit 1
fi

# Check if base image exist
if [[ "$(docker images -q onh-base:$1 2> /dev/null)" == "" ]]; then

	# Build image
	docker build --tag onh-base:$1 .
fi

# Check if base image exist
if [[ "$(docker images -q onh-base:$1 2> /dev/null)" != "" ]]; then

	# Run clean base container
	docker run -d --name onh-test --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro onh-base:$1

	# Copy prepare script
	docker cp scripts/onhPrepare.sh onh-test:/home/onh/

	# Run script
	docker exec -it --user=onh onh-test bash /home/onh/onhPrepare.sh

	# Remove prepare script from container
	docker exec onh-test rm /home/onh/onhPrepare.sh

	# Stop container
	docker stop onh-test

	# Create image
	docker commit -m "$3" -a "$4" onh-test onh-clean:$2

	# Remove temporary container
	docker rm onh-test
fi
