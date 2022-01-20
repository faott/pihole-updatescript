#!/bin/bash

# Fileversion V2 / pihole_update_v2.sh

# Das Programm stopt die Service's im Zusammenhang mit den Pihole Subsystemen
# anschliessend wird zuerst das Betriebssystem und danach das Pihole System updatet.

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

check_lighttpd() {

    STATUS="$(systemctl is-active lighttpd.service)"

    case $STATUS in

        inactive)
        echo -e "The LIGHTTPD Service is ${RED}${STATUS}${NOCOLOR}"
        ;;

        active)
        echo -e "The LIGHTTPD Service is ${GREEN}${STATUS}${NOCOLOR}"
        ;;

        *)
        echo -e "${RED}LIGHTTPD Service Status UNKNOWN${NOCOLOR}"
        ;;
    esac
}

check_dhcpcd() {

    STATUS="$(systemctl is-active dhcpcd.service)"

    case $STATUS in

        inactive)
        echo -e "The DHCPCD Service is ${RED}${STATUS}${NOCOLOR}"
        ;;

        active)
        echo -e "The DHCPCD Service is ${GREEN}${STATUS}${NOCOLOR}"
        ;;

        *)
        echo -e "${RED}DHCPCD Service Status UNKNOWN${NOCOLOR}"
        ;;
    esac
}

check_piholeftl() {

    STATUS="$(systemctl is-active pihole-FTL.service)"

    case $STATUS in

        inactive)
        echo -e "The PIHOLE-FTL Service is ${RED}${STATUS}${NOCOLOR}"
        ;;

        active)
        echo -e "The PIHOLE-FTL Service is ${GREEN}${STATUS}${NOCOLOR}"
        ;;

        *)
        echo -e "${RED}PIHOLE-FTL Service Status UNKNOWN${NOCOLOR}"
        ;;
    esac
}

check_piholeads() {

    if pihole status | grep -q 'enabled'
        then
            echo -e "The PIHOLE-BLOCKING is ${GREEN}enabled${NOCOLOR}"
    elif pihole status | grep -q 'disabled'
        then
            echo -e "The PIHOLE-BLOCKING is ${RED}disabled${NOCOLOR}"
    else
        echo -e "${RED}PIHOLE-BLOCKING Status UNKNOWN${NOCOLOR}"
    fi
}

echo
echo -e "${RED}This is the Pihole UpdateScript${NOCOLOR}"
echo
echo -e "step 1: ${GREEN}status check${NOCOLOR}"
echo "--------------------------------------"

check_lighttpd
check_dhcpcd
check_piholeftl
check_piholeads

echo "Pihole Update Check"
pihole -up --check-only
echo

read -r -p "Do you like to run the Update-Script? Type 'yes' to run or anything else to abort: " answer_run
echo "$answer_run"

if [ "$answer_run" == "yes" ]
    then
        echo -e "step 2: ${GREEN}stopping services${NOCOLOR}"
        echo "--------------------------------------"
        pihole disable
        check_piholeads
        systemctl stop pihole-FTL.service
        check_piholeftl
        systemctl stop lighttpd.service
        check_lighttpd
        systemctl stop dhcpcd.service
        check_dhcpcd
        echo

        echo -e "step 3: ${GREEN}updating os${NOCOLOR}"
        echo "--------------------------------------"
        apt-get update
        echo
        apt-get upgrade
        echo

        echo -e "step 4: ${GREEN}updating pihole${NOCOLOR}"
        echo "--------------------------------------"
        pihole -up
        echo

        echo -e "step 5: ${GREEN}restarting services${NOCOLOR}"
        echo "--------------------------------------"
        systemctl start pihole-FTL.service
        check_piholeftl
        pihole enable
        check_piholeads
        systemctl start lighttpd.service
        check_lighttpd
        systemctl start dhcpcd.service
        check_dhcpcd
        echo

        echo -e "step 6: ${GREEN}update finish${NOCOLOR}"
        echo "--------------------------------------"
        echo "Update finished. Check output for restarted services. Consider rebooting the System......"
        exit 0

    else
        echo "Not Updating. Exiting!"
        exit 0
fi