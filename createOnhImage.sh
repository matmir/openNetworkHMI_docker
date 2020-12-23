#!/bin/bash

# Input parameters
PARAM_BRANCH="$5"
PARAM_ASK="$6"
PARAM_TEST="$7"

# Check install script params
check_params() {

	# Ask select
	if [ -z "$PARAM_ASK" ]
	then
    	echo "No asking mode"
	else
		if [ "$PARAM_ASK" = "ask" ]
		then
			echo "Asking mode ON"
		elif [ "$PARAM_ASK" = "askOFF" ]
		then
			echo "Asking mode OFF"
		else
			echo "Invalid ASK parameter"
			exit 1
		fi
	fi

	# Tests select
	if [ -z "$PARAM_TEST" ]
	then
    	echo "No test build"
	else
		if [ "$PARAM_TEST" = "test" ]
		then
			echo "Test build ON"
		elif [ "$PARAM_TEST" = "testOFF" ]
		then
			echo "Test build OFF"
		else
			echo "Invalid TEST parameter"
			exit 1
		fi
	fi

	return 0
}

# Stop test container
stopTestContainer() {

	# Stop container
	docker stop onh-test

	if [ "$?" -ne "0" ]
	then
		echo "Can not stop test container - check logs"
		exit 1
	fi
}

# Remove test container
removeTestContainer() {

	# Remove temporary container
	docker rm onh-test

	if [ "$?" -ne "0" ]
	then
		echo "Can not remove test container - check logs"
		exit 1
	fi
}

# Check arguments
if [ $# -lt 4 ] || [ $# -gt 7 ]
then
	echo "Usage: ./createOnhImage.sh baseImageTag cleanImageTag CommitComment CommitUser [branchName] [askMode] [buildTest]"
	exit 1
fi

check_params

# Check if base image exist
if [[ "$(docker images -q onh-base:$1 2> /dev/null)" == "" ]]; then

	# Build image
	docker build --tag onh-base:$1 .

	if [ "$?" -ne "0" ]
	then
		echo "Building base image failed - check logs"
		exit 1
	fi
fi

# Check if base image exist
if [[ "$(docker images -q onh-base:$1 2> /dev/null)" != "" ]]; then

	# Run clean base container
	docker run -d --name onh-test --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro onh-base:$1

	if [ "$?" -ne "0" ]
	then
		echo "Running base image failed - check logs"
		exit 1
	fi

	# Copy prepare script
	docker cp scripts/onhPrepare.sh onh-test:/home/onh/

	if [ "$?" -ne "0" ]
	then
		stopTestContainer
		removeTestContainer

		echo "Copy initial script failed - check logs"
		exit 1
	fi

	# Run script
	docker exec -it --user=onh onh-test bash /home/onh/onhPrepare.sh $PARAM_BRANCH $PARAM_ASK $PARAM_TEST

	if [ "$?" -ne "0" ]
	then
		stopTestContainer
		removeTestContainer

		echo "Running initial script failed - check logs"
		exit 1
	fi

	# Remove prepare script from container
	docker exec onh-test rm /home/onh/onhPrepare.sh

	if [ "$?" -ne "0" ]
	then
		stopTestContainer
		removeTestContainer

		echo "Remove initial script failed - check logs"
		exit 1
	fi

	# Stop container
	stopTestContainer

	# Create image
	docker commit -m "$3" -a "$4" onh-test onh-clean:$2

	if [ "$?" -ne "0" ]
	then
		removeTestContainer

		echo "Create image failed - check logs"
		exit 1
	fi

	# Remove temporary container
	removeTestContainer
fi
