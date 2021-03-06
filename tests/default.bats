#!/usr/bin/env bats

SUT_CONTAINER=bats-jenkins

load lib/test_helpers

@test "------ preparing $(basename $BATS_TEST_FILENAME .bats) ------" {
    docker_clean $SUT_CONTAINER
}

@test "SUT container created" {
    docker run -d --name $SUT_CONTAINER -P $SUT_IMAGE
}

################################################################################

@test "Jenkins is initialized" {
    retry 30 5 jenkins_url /
}

@test "job SeedJob exists" {
    retry 5 2 jenkins_url /job/SeedJob/
}

@test "job SeedJob build #1 created" {
    retry 5 2 jenkins_url /job/SeedJob/1/
}

@test "job SeedJob last build suceeded" {
    jenkins_job_success SeedJob || {
        echo -e "\n\n---------------------------------------------------------"
        curl --silent --fail $(get_jenkins_url)/job/SeedJob/lastBuild/consoleText
        echo -e "---------------------------------------------------------\n\n"
        false
    }
}

################################################################################

@test "job 'Example 1' exists" {
    retry 15 1 jenkins_url /job/Example%201/
}

@test "job 'Example with docker' exists" {
    retry 15 1 jenkins_url /job/Example%20with%20docker/
}
