FROM debian:bullseye-slim

LABEL com.virtualeria.vendor="Virtual Eria"
LABEL version="1.0"
LABEL description="This is a Dockerfile to \
autogenerate a fabric minecraft server."
LABEL com.virtualeria.authors="apalfonso23@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/VirtualEriaLabs/docker-fabric-server"

ARG DEBIAN_FRONTEND=noninteractive

# Installers
ARG FABRIC_INSTALLER=https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.7.4/fabric-installer-0.7.4.jar
ARG FABRIC_INSTALLER_NAME=fabric-installer-0.7.4.jar

# Path Args
ARG SV_PATH=/var/minecraft-server
ARG RUNNER_NAME=startup.sh
ARG RUNNER_DEBUG_NAME=startup-debug.sh
ARG RUNNER_DEBUG_CLASS_NAME=startup-debug-class.sh

# Build stage
RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
            ${SV_PATH} \
            ${SV_PATH}/mods \
            ~/.gnupg \
    && groupadd -r eriacraft \
    && useradd -r -s /bin/false -g eriacraft eriacraft \
    && echo "deb [signed-by=/usr/share/keyrings/linuxuprising-java-archive-keyring.gpg] http://ppa.launchpad.net/linuxuprising/java/ubuntu focal main" | tee /etc/apt/sources.list.d/linuxuprising-java.list \
    && echo oracle-java16-installer shared/accepted-oracle-license-v1-2 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y \
        gnupg2 \
        wget \
    && gpg --no-default-keyring --keyring /usr/share/keyrings/linuxuprising-java-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 73C3DB2A \
    && apt-get update \
    && apt -y install oracle-java16-installer --install-recommends \
        oracle-java16-set-default \
        screen \
        nano \
        zip \
    && apt-get clean
COPY ${RUNNER_NAME} ${SV_PATH}/${RUNNER_NAME}
COPY ${RUNNER_NAME} ${SV_PATH}/${RUNNER_DEBUG_NAME}
COPY ${RUNNER_NAME} ${SV_PATH}/${RUNNER_DEBUG_CLASS_NAME}
WORKDIR $SV_PATH
RUN wget -O ${FABRIC_INSTALLER_NAME} ${FABRIC_INSTALLER} \
    && java -jar ${FABRIC_INSTALLER_NAME} server -downloadMinecraft \
    && rm -rf ${FABRIC_INSTALLER_NAME} \
    && rm -rf .fabric-installer \
    && java -jar fabric-server-launch.jar \
    && sed -i 's/eula=false/eula=true/g' eula.txt \
    && chown -R eriacraft:eriacraft ${SV_PATH} \
    && chmod 700 ${RUNNER_NAME}
EXPOSE 25565
EXPOSE 8000
CMD ["bash","./startup.sh"]

