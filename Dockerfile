FROM docker.ocf.berkeley.edu/theocf/debian:jessie

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        cracklib-runtime \
        libcrack2-dev \
        libssl-dev \
        python3 \
        python3-dev \
        python3-pip \
        redis-tools \
        sudo \
        virtualenv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN install -d --owner=nobody /opt/create /opt/create/venv

COPY requirements.txt /opt/create/
RUN virtualenv -ppython3 /opt/create/venv \
    && /opt/create/venv/bin/pip install pip==8.1.2 \
    && /opt/create/venv/bin/pip install \
        -r /opt/create/requirements.txt

COPY etc/sudoers /etc/sudoers.d/create
COPY create /opt/create/create

# TODO: remove this after ocflib no longer calls nscd
RUN ln -s /bin/true /usr/sbin/nscd

USER nobody
WORKDIR /opt/create
ENV PATH=/opt/create/venv/bin:$PATH
CMD ["/opt/create/venv/bin/python", "-m", "create.worker"]