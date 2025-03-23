# Dante Pinggoy - Python App

##Deploy Python App

1. Initial setup
    - In the VPS server git clone from your sample app
	    - git clone https://github.com/pinggoydb/sample-python-app-docker.git
	    - Go to your app `cd sample-python-app-docker`
	    - docker compose up
    
    compose.yaml
    ```bash
    services:
        web:
            build: .
            ports:
                - 80:5000
    ```

2. Setup Nginx
	- Create a file `nginx/nginx.conf` with config

    ```bash
    events {
        worker_connections 1024;
    }

    http {
        server_tokens off;
        charset utf-8;

        server {
            listen 80 default_server;

            server_name _;

            location / {
                proxy_pass http://web:5000/;
            }
        }
    }
    ```
	- Add nginx container in compose.yaml
    ```bash
	nginx:
	  restart: unless-stopped
	  image: nginx
	  ports:
	    - 80:80
	    - 443:443
	  volumes:
	    - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    ```
	- Remove the port section in web
    ```bash
		ports:
			- 80:5000
    ```

3. Setup SSL with Letsencrypt
	- Add location in nginx.conf http with
	 ``bash
     location ~ /.well-known/acme-challenge/ {
          root /var/www/certbot;
      }
    ```

    - Add cerbot volume in nginx and certbot image
    ```bash
    volumes
        - ./certbot/conf:/etc/letsencrypt
        - ./certbot/www:/var/www/certbot
    ```
    ```bash
    certbot:   
        image: certbot/certbot
        container_name: certbot
        volumes:
            - ./certbot/conf:/etc/letsencrypt
            - ./certbot/www:/var/www/certbot
        command: certonly --webroot -w /var/www/certbot --force-renewal --email {email} -d {email} --agree-tos
    ```

    - Your `compose.yaml` would look like this and update your domain accordingly.

    ```bash
    services:
    web:
        build: .

    nginx:
        restart: unless-stopped
        image: nginx
        ports:
        - 80:80
        - 443:443
        volumes:
        - ./nginx/nginx.conf:/etc/nginx/nginx.conf
        - ./certbot/conf:/etc/letsencrypt
        - ./certbot/www:/var/www/certbot
    
    certbot:   
        image: certbot/certbot
        container_name: certbot
        volumes:
            - ./certbot/conf:/etc/letsencrypt
            - ./certbot/www:/var/www/certbot
        command: certonly --webroot -w /var/www/certbot --force-renewal --email {email} -d {domain} --agree-tos
    ```

    - Your `nginx.conf` would look like this.
    ```bash
    events {
        worker_connections 1024;
    }

    http {
        server_tokens off;
        charset utf-8;

        server {
            listen 80 default_server;

            server_name _;

            location / {
                proxy_pass http://web:5000/;
            }
            
            location ~ /.well-known/acme-challenge/ {
                root /var/www/certbot;
            }
        }
    }   
    ```

    - In you domain provider, add an A record like sample below
        | Type | Hostname       | Value          | 	TTL (seconds)|
        | -----| -------------- | -------------- | ------------- |
        | A    | yourdomain.com | 159.223.80.135 | 3600          |
        
