FROM nginx:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends 

RUN apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    python3-venv \
    uwsgi \
    libpcre3 \
    libpcre3-dev \
    build-essential \
    python3-dev
    

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install pipenv
RUN pip install --upgrade pip && pip install uwsgi flask boto3


RUN apt-get remove --purge -y gnupg lsb-release && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# install our code
ADD . /home/docker/code/
WORKDIR /home/docker/code

# Configure Nginx
RUN ln -s /home/docker/code/nginx-app.conf /etc/nginx/conf.d/
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.ORIGINAL
RUN chmod +x /home/docker/code/start.sh


# Start uWSGI daemon
EXPOSE 80 
CMD ["./start.sh"]
