# Start/stop script when server is started/shutdown

1. Create scripts for start and stop, for example:
    ~~~
    /opt/scripts/start_script.sh
    /opt/scripts/stop_script.sh
    ~~~
1. Make the scripts executable `chmod +x script_name`.
1. Create systemd file
    * /etc/systemd/system/start_and_stop.service
        ~~~
        [Unit]
        Description=Start and stop scripts on startup and shutdown.

        [Service]
        User=root
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/opt/scripts/start_script.sh
        ExecStop=/opt/scripts/stop_script.sh

        [Install]
        WantedBy=multi-user.target
        ~~~
1. Enable the Service with the command:
    ~~~
    systemctl enable start_and_stop
    ~~~
1. Now one can also start and stop the scripts via systemctl. This is also good test to check if the script is run properly.
    ~~~
    sudo systemctl start start_and_stop
    ~~~
1. Reboot machine to test that the script is run properly.
