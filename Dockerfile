FROM ubuntu:22.04

USER root
ARG DEBIAN_FRONTEND=noninteractive
ARG GID=1000
ARG UID=1000
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV SHELL="/bin/bash"
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update -y > /dev/null && \
    apt install -y software-properties-common && \
    apt install -y bzip2 ca-certificates curl expect ftp git gnupg && \
    apt install -y python3 python3-dev python3-pip python3-venv && \
    apt install -y sudo unzip vim wget xz-utils zip
RUN apt autoremove --purge -y > /dev/null && \
    apt autoclean -y > /dev/null && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/* && \
    rm -rf /tmp/*
RUN echo "alias pip=pip3" | tee --append /etc/bash.bashrc && \
    echo "alias python=python3" | tee --append /etc/bash.bashrc && \
    echo "StrictHostKeyChecking no" | tee --append /etc/ssh/ssh_config && \
    echo "craftslab ALL=(ALL) NOPASSWD: ALL" | tee --append /etc/sudoers && \
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash && \
    groupadd -g $GID craftslab && \
    useradd -d /home/craftslab -ms /bin/bash -g craftslab -u $UID craftslab

USER craftslab
WORKDIR /home/craftslab
RUN git clone https://github.com/microsoft/PromptWizard.git promptwizard --depth=1

USER craftslab
WORKDIR /home/craftslab/promptwizard
COPY promptwizard.patch .
RUN git apply promptwizard.patch && \
    rm -f promptwizard.patch
COPY requirements.txt .
RUN pip install -r requirements.txt && \
    rm -f requirements.txt

USER craftslab
WORKDIR /home/craftslab/promptwizard
ENTRYPOINT ["python3", "prompt.py"]
CMD ["--help"]
