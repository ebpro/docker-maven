#!/bin/bash

IMAGE_NAME="brunoe/maven"

## search docker images by tags and build new tags from last updates
# $1 docker account
# $2 docker repository
# Eregexp to keep tags
_docker_images_tag() {
curl -s -L --fail "https://hub.docker.com/v2/repositories/$1/$2/tags/?page_size=1000" | \
        jq '.results | .[] | .name +" " + .last_updated' -r | \
        grep -E "$3" | \
		sed  -e 's/latest/latest/g' \
			 -e 's/\([^ ]*\) \([^ ]*\)/ echo "\1,-t $IMAGE_NAME:\1-"$(date --date="\2" +%s) -t $IMAGE_NAME:\1 -t $(echo $IMAGE_NAME:\1| sed -E "s\/(-eclipse-temurin|-focal)\/\/g") -t $IMAGE_NAME:$(echo \1| sed -E "s\/(-eclipse-temurin|-focal)\/\/g"|cut -d '-' -f 2)/'| \
		eval "$(cat -)" | \
		sort
}

build-and-push() {
	local IFS=$'\n'
	# We compute the name and tags from the latests official images
	nameAndTags=($(_docker_images_tag library maven "^[0-9]+\.[0-9]+\.[0-9]+-eclipse-temurin-[0-9]+-focal|latest"))
	for image in ${nameAndTags[@]}; do
		fromImage=$(echo $image|cut -f 1 -d ',')
		tags=$(echo $image|cut -f 2 -d ',')
		# we build	
		buildCommand="DOCKER_BUILDKIT=1 docker build --progress=plain --build-arg MAVEN_BASEIMAGE=maven:$fromImage $tags ."
		eval $buildCommand

		local IFS=$' '
		# and we push tags extracted from the command
		for imageName in $(echo $tags|sed s'/-t //g'|tr -s ' '|sort|uniq); do
			docker push $imageName
		done
	done
}

build-and-push

