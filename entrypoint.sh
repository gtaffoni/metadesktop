#!/bin/bash

# Exit on any error. More complex stuff could be done in future
# (see https://stackoverflow.com/questions/4381618/exit-a-script-on-error)
set -e

GUI=True



if [ "x$SAFE_MODE" == "xTrue" ]; then

    echo ""
    echo "[INFO] Not executing entrypoint as we are in safe mode, just opening a Bash shell."
    exec /bin/bash

else

    echo ""
    echo "[INFO] Executing entrypoint..."
    
    if [ "x$GUI" == "xTrue" ]; then
	    if [ "x$BASE_PORT" == "x" ]; then
	        echo "[INFO] No task base port set, will set KasmVNC port 8443 with  desktop id \"1\""  
	    else 
	        echo "[INFO] Task base port set, will set KasmVNC port $BASE_PORT with desktop id \"$(($BASE_PORT-5900+1))\""
	    fi
    fi
    
    #---------------------
    #   Setup home
    #---------------------

    if [ ! -f "/home/skauser/.initialized" ]; then
        echo "[INFO] Setting up home"
	[ ! -d "/home/skauser" ] &&  mkdir -p /home/skauser
        # Copy over vanilla home contents
        for x in /skauser_home_vanilla/* /skauser_home_vanilla/.[!.]* /skauser_home_vanilla/..?*; do
            if [ -e "$x" ]; then cp -a "$x" /home/skauser/; fi
        done
        
        # Mark as initialized
	[ ! -f "/home/skauser/.initialized" ] && touch /home/skauser/.initialized
    fi
    

    #---------------------
    #   Save env
    #---------------------
    echo "[INFO] Dumping env"
    
    # Save env vars for later usage (e.g. ssh)
    
    env | \
    while read env_var; do
      if [[ $env_var == HOME\=* ]]; then
          : # Skip HOME var
      elif [[ $env_var == PWD\=* ]]; then
          : # Skip PWD var
      else
          echo "export $env_var" >> /tmp/env.sh
      fi
    done
    cd /home/skauser 
    #---------------------
    #   VNC Password
    #---------------------
    if [ "x$GUI" == "xTrue" ]; then
	    if [ "x$AUTH_PASS" != "x" ]; then
	        echo "[INFO] Setting up VNC password..."
	        /usr/local/bin/kasmvncpasswd -f <<< $AUTH_PASS > /home/skauser/.kasmpasswd
	        chmod 600 /home/skauser/.kasmpasswd
	        export VNC_AUTH=True
	    else
	        echo "[INFO] Not setting up any VNC password"
	            
	    fi
    fi
    
	echo "[INFO] Creating /tmp/skauserhome to be used as skauser home"
	mkdir /tmp/skauserhome
	
	echo "[INFO] Initializing /tmp/skauserhome with configuration files"
	cp -aT /skauser_home_vanilla /tmp/skauserhome
	
	echo "[INFO] Moving to /home/skauser and setting as home"
	cd /home/skauser
	export HOME=/home/skauser
	
	echo "[INFO] Setting new prompt @$CONTAINER_NAME container"
	echo 'export PS1="${debian_chroot:+($debian_chroot)}\u@$CONTAINER_NAME@\h:\w\$ "' >> /tmp/skauserhome/.bashrc
        
	
    # Set entrypoint command
	if [ "x$@" == "x" ]; then
	    if [ "x$GUI" == "xTrue" ]; then
            COMMAND="supervisord -c /etc/supervisor/supervisord.conf"
	    else
	        COMMAND="/bin/bash"
	    fi
	else
	    COMMAND="$@"
	fi
	

    # Start!
	echo -n "[INFO] Will execute entrypoint command: "
	echo $COMMAND
	echo ""
	echo "=============================================================="
	echo ""
	echo "      Welcome to the EUROEXA $CONTAINER_NAME container!"
	echo ""
	echo "=============================================================="
	echo ""
	echo "You are now in /home/skauser with write access as user \"$(whoami)\"."
	echo ""
	echo "Remember that contents inside this container, unless stored"
	echo "on a persistent volume mounted from you host machine, will"
	echo "be wiped out when exiting the container."
	echo ""
	
	exec $COMMAND
fi
