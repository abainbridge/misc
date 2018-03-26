#!/bin/bash

# Add stuff to .bashrc
cat <<'heredoc1' >>/home/epcadmin/.bashrc
    #    < Set window title > <- Cyan   ->        <- Yellow ->   <- Green -->  <Normal >
    PS1='\[\033]0;\u@\h\007\] \[\e[1;36m\]\n\u@\h \[\e[1;33m\]\t \[\e[1;32m\]\w\[\e[0m\]\n\$ '

    # Update the BASH history file after each command, so if the sessions crashes/is
    # terminated, we get to keep the history
    shopt -s histappend
    PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

    PROMPT_COMMAND="pwd > ~/.lastdir;$PROMPT_COMMAND"
    cd `cat ~/.lastdir`

    shopt -s checkwinsize
    shopt -s no_empty_cmd_completion
    shopt -s nocaseglob         # Make the * wildcard case insensitive
    export HISTCONTROL=ignoreboth:erasedups

    alias ls='ls -oAF --color --group-directories-first'
heredoc1


# Create udp_responder.py
cat <<'heredoc2' >>/home/epcadmin/udp_responder.py
import socket
import sys
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
our_addr = socket.gethostbyname(socket.gethostname())
port = 2123
sock.bind((our_addr, port))
print 'Listening on', our_addr, 'port', port
sys.stdout.flush()
while True:
    buf, addr = sock.recvfrom(1024)
    print 'Received:', buf, 'From:', addr
    sys.stdout.flush()
    sock.sendto('hello from ' + our_addr, addr)
    print 'Sent response'
    sys.stdout.flush()
heredoc2


# Add udp_responder.py to crontab
crontab -l >ct
echo '@reboot python2 /home/epcadmin/udp_responder.py >/home/epcadmin/udp_responder.log 2>&1' >>ct
echo '@reboot date >/home/epcadmin/boot_time.txt' >>ct
crontab ct


nohup python2 /home/epcadmin/udp_responder.py >/home/epcadmin/udp_responder.log 2>&1 &
