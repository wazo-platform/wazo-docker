## How to generate certificates

openssl req -x509 -sha256 -nodes -days 825 -newkey rsa:2048 -config openssl.cfg -keyout server.key -out server.crt
