FROM registry.access.redhat.com/ubi9/python-311
USER 0

RUN mkdir /app && \
    chmod 655 /app

WORKDIR /app

COPY requirements/requirements.txt main.py entrypoint.sh ./
RUN pip install --upgrade pip && \
    pip3 install -r requirements.txt

ENTRYPOINT [ "bash", "entrypoint.sh" ]
