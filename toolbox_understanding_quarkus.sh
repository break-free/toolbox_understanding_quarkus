#!/bin/bash

#title       :  toolbox_quarkus.sh
#description :  This script will create a toolbox to support following the
#             guide by Antonio Goncalves, _Understanding Quarkus_ (2020).
#author      :  Chris Mills, cmills@breakfreesolutions.com
#notes       :  `toolbox`, `podman` and `minikube` must be installed on the
#             local host. GraalVM and Kafka tar files for installation must
#             also be downloaded in to the same folder where this script is
#             executed.
#               Also note that this has been solely tested and used on Fedora
#             Kinoite 37; other OS and versions have not been tested. The
#             _Understanding Quarkus_ fascicle used as a reference was
#             released 27 Oct 2020.

# Create container

NAME=quarkus
echo -e "\n## Create $NAME container\n"

toolbox rm --force $NAME || true
toolbox create --container $NAME

# Install applications via dnf

echo -e "\n## Install $NAME tools and applications\n"

## Setup variable for easy invocation of toolbox
RUN="toolbox run --container $NAME"

## Install applications

APPLICATIONS=(java-11-openjdk-devel \
              maven)

echo "### Installing applications:"
for app in ${APPLICATIONS[@]}; do
  echo -e "\n--- Installing $app ---\n";
  $RUN sudo dnf install -y $app;
  echo -e "\n--- $app installed ---\n";
done


## Exit after applications installation

echo -e "\n## Completed installation of:\n"
for app in ${APPLICATIONS[@]}; do
  echo "--- $app";
done

# Install additional binaries, etc.

## Install GraalVM from local (i.e,` ./`)tar file.
$RUN tar -xvf graalvm*.tar.gz
$RUN sudo mv graalvm*/ /opt/graalvm/
$RUN /opt/graalvm/bin/gu install native-image
$RUN sudo bash -c 'echo -e "GRAALVM_HOME=/opt/graalvm" \
                    > /etc/profile.d/graalvm.sh'

## Install Kafka from local (i.e., './') tar file
$RUN tar -xzf kafka*.tgz
$RUN sudo mv kafka*/ /opt/kafka/
$RUN sudo bash -c 'echo -e "PATH=\$PATH:/opt/kafka/bin" \
                     > /etc/profile.d/kafka.sh'

## Link `podman` and 'minikube' to local host binaries
$RUN sudo bash -c 'echo -e "\
alias docker='\''flatpak-spawn --host /usr/bin/podman'\'' \n\
alias docker-compose='\''flatpak-spawn --host /usr/bin/podman-compose'\'' \n\
alias podman='\''flatpak-spawn --host /usr/bin/podman'\'' \n\
alias minikube='\''flatpak-spawn --host /usr/local/bin/minikube'\'' \n\
alias kubectl='\''flatpak-spawn --host /usr/local/bin/minikube kubectl'\'' \n\
alias k='\''kubectl'\'' "\
> /etc/profile.d/quarkus.sh'
