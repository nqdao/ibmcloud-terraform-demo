FROM ibmterraform/terraform-provider-ibm-docker:v1.2.4

RUN set -ex \
        && apk update \
        && apk add --no-cache --virtual .build-python \
        && apk add python3 python3-dev build-base libffi-dev openssl-dev openssh qemu-img rsync \
        && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
        && echo "**** install pip ****" \
        && python3 -m ensurepip \
        && rm -r /usr/lib/python*/ensurepip \
        && pip3 install --no-cache --upgrade pip setuptools wheel ansible netaddr \
        && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
        && apk del .build-python

CMD ["/bin/bash"]
