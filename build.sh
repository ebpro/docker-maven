MAVEN_BASEIMAGE=maven:3.8.6-eclipse-temurin-17 && 
	docker build \
		--build-arg MAVEN_BASEIMAGE=$MAVEN_BASEIMAGE \
		-t brunoe/$MAVEN_BASEIMAGE .

