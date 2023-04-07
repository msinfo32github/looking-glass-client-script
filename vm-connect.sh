#!/bin/bash

# GUI

# Using 'dialog' for a dialog box. See: https://linux.die.net/man/1/dialog

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="vm-connect"
TITLE="Title here"
MENU="Choose one of the following options:"

# List of options using dialog box.


OPTIONS=(1 "Re-connect to a running VM"
         2 "Start a new connection"
         3 "Shut down a VM"
         4 "Query all VMs status"
         5 "Query inactive VMs status"
         6 "Query running VMs status"
         7 "Query VM network information"
         8 "Exit")

# Sets the dialog settings

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

# Clear the terminal screen

clear

# Create a named pipe (a temporary pipe)

#rm /tmp/vmcPipe1
#clear
#mkfifo /tmp/vmcPipe1

# Make the commands work

case $CHOICE in
        1)
            echo "Re-connecting to a running VM..."
            # Using 'looking-glass-client'. If this does not work, check that 'looking-glass-client' is stored in /usr/bin/ (Follow wiki!)
            looking-glass-client -F
            ;;
        2)

            # below code taken from askubuntu stackexchange (src: https://askubuntu.com/questions/491509/how-to-get-dialog-box-input-directed-to-a-variable)
            mkfifo /tmp/namedPipe1 # this creates named pipe, aka fifo

            # to make sure the shell doesn't hang, we run redirection 
            # in background, because fifo waits for output to come out    
            dialog --inputbox "Which VM do you want to start?" 40 40 2> /tmp/namedPipe1 & 

            # release contents of pipe
            vm="$( cat /tmp/namedPipe1  )" 
            clear
            echo  "Starting VM: " $vm

            # set /dev/shm/looking-glass permissions to libvirt-qemu:libvirt-qemu (Required to start VM)

            sudo chown libvirt-qemu:libvirt-qemu /dev/shm/looking-glass

            # start inputted vm

            sudo virsh start $vm
            
            # wait 3 seconds for VM to initialize

            sleep 3

            # give /dev/shm/looking-glass permissions back to your current user

            sudo chown $USER:libvirt-qemu /dev/shm/looking-glass

            # open looking glass (typically stored in /usr/bin/looking-glass-client)

            looking-glass-client -F

            # clean up
            rm /tmp/namedPipe1
            ;;
        3)
            echo "Shut down a VM"
            # below code taken from askubuntu stackexchange (src: https://askubuntu.com/questions/491509/how-to-get-dialog-box-input-directed-to-a-variable)
            mkfifo /tmp/namedPipe2 # this creates named pipe, aka fifo

            # to make sure the shell doesn't hang, we run redirection 
            # in background, because fifo waits for output to come out    
            dialog --inputbox "Which VM do you want to start?" 40 40 2> /tmp/namedPipe2 & 

            # release contents of pipe
            shutdownvm="$( cat /tmp/namedPipe2  )" 
            clear
            echo  "Stopping VM: " $shutdownvm

            # shutdown inputted vm

            sudo virsh shutdown $shutdownvm

            # clean up
            rm /tmp/namedPipe2
            ;;
        4)
            echo "Listing all VMs..."
            # Listing output of sudo virsh list --all
            sudo virsh list --all
            ;;
        5)
            echo "Querying inactive VMs status..."
            # Listing output of sudo virsh list --inactive
            sudo virsh list --inactive
            ;;
        6)
            echo "Querying running VMs status..."
            # Listing output of sudo virsh list
            sudo virsh list
            ;;
        7)
            echo "Checking VM network information..."
            # below code taken from askubuntu stackexchange (src: https://askubuntu.com/questions/491509/how-to-get-dialog-box-input-directed-to-a-variable)
            mkfifo /tmp/namedPipe3 # this creates named pipe, aka fifo

            # to make sure the shell doesn't hang, we run redirection 
            # in background, because fifo waits for output to come out    
            dialog --inputbox "Which VM network information do you want?" 40 40 2> /tmp/namedPipe3 & 

            # release contents of pipe
            netvm="$( cat /tmp/namedPipe3  )" 
            clear
            echo  "Network information: " $netvm
            sudo virsh domifaddr $netvm
            ;;
        8)
            echo "Exiting..."
            exit
            ;;
esac
