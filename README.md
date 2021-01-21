# Contenerized Linux Web Remote Desktop

Web based  Meta Desktop for containerasing GUI applications based on KasmVNC

https://github.com/kasmtech/KasmVNC

and

https://github.com/sarusso/MetaDesktop


The container has been designed to run on singularity and docker.

The desktop enviroment is ubuntu:18.04 lxde

##Building

```sh
sudo docker build -t minimalwebdesktop -f Dockerfile .
```

### Running

The container use a set of enviromental variables:

| variable | Description |
| -------- | ----------- |
| VNC_AUTH | activate VNC authentication and SSL |
| NOHTTPS | enable HTTPS connection |
| BASE_PORT | The port to use for the web socket. Use a high port to avoid having to run as root. |
| AUTH_USER | user to access web VNC (default: metauser) |
| AUTH_PASS | password to access web VNC (default: metapasswd) |


```sh
sudo docker run -it -p 8443:8443 --rm -e "AUTH_USER=metauser" -e "AUTH_PASS=passwd123" -e "BASE_PORT=8443"  minimalwebdesktop
```

Now navigate to https://<ip-address>:8443

