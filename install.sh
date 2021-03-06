#!/bin/bash

# Gebruikers variabelen
HOSTNAME='HAN'	# Hostname die deze pi moet krijgen
USERNAME='pi'	# Gebruikersnaam van de gebruiker waarvoor han4pi geinstalleerd moet worden.

# Andere variabelen die noodzakelijk zijn voor het script
VERSION='0'
SKIP=false
ret=false

# Bekijk of er parameters meegegeven zijn.
while getopts 'hlvs' flag; do
  case "${flag}" in
    h) echo "$(pwd)/bash/resources/help" 
	flagDetection=true
	exit 1;;
    l) 	cat "$(pwd)/LICENSE"
	flagDetection=true 
	exit 1;;
	v) echo $VERSION
	exit 1;;
	s) SKIP=true;;
    *) echo "Unexpected option ${flag}"
	exit 1;;
  esac
done

# Controlleer of de opgegeven gebruikersnaam bij een gebruiker hoort.
getent passwd "$USERNAME" >/dev/null 2>&1 && ret=true

if ! $ret; then
    echo "Er is geen gebruikersnaam bij de ingestelde gebruikersnaam."
    exit 0
fi

# Controlleer of de opgegeven gebruiker een home map heeft, zo niet maak er een.
mkdir -p /home/"$USERNAME"

# Controlleer op root
if [[ $EUID -ne 0 ]]; then
   echo "Dit script moet met root rechten worden uitgevoerd.
Dit kunt u doen door het aan te roepen met sudo. (sudo bash scriptnaam.sh)
   " 1>&2
   exit 1
fi

# Controlleer of github.com werkt, zo niet dan kan het script niet verder gaan
curl http://www.github.com.com 2>/dev/null > /tmp/webtest.txt
if [[ $? != 0 ]]; then
  echo 'Er kan geen verbinding met github gemaakt worden.'
  echo 'Een verbinding met github is vereist en de installatie zal daarom gestopt worden.'
  exit 1
fi

# Even weer een schoon scherm tonen
clear

# Zet wat kleur variabelen
RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'
NC='\033[0m'

if [ "$SKIP" = false ]; then

	# Print het han logo
	
	echo -e ${BLUE}10011110000101000010100101000011011011010000001001011000010001111111110011111111
	echo -e ${BLUE}01101001110101110001000010111101001101000011101000011101000001110111101100101110
	echo -e ${BLUE}10001010101110001111011110111111011101100110111010001010101001011001111010011001
	echo -e ${BLUE}01001110011100000010001110001101000100110111101110101111111100111100000010101000
	echo -e ${BLUE}00100001001011011001101100001001111111100001100110111101010101000110100000010000
	echo -e ${BLUE}11001111110100110000110001010010100110100010001111100011101101111010110101000010
	echo -e ${BLUE}00010101001100101010001111001011110101001110111001010011111010011110010100001010
	echo -e ${BLUE}01001011100000100001100000100010101111100000100101110011110001110001011110111100
	echo -e ${BLUE}01010${RED}00${BLUE}00100101010001${WHITE}110${BLUE}0101${WHITE}111${BLUE}01101111011${WHITE}011${BLUE}01110110100${WHITE}0101${BLUE}100${WHITE}110${BLUE}10010010011011
	echo -e ${BLUE}00010${RED}0111${BLUE}000000100011${WHITE}011${BLUE}0110${WHITE}100${BLUE}1110111001${WHITE}00011${BLUE}0111011001${WHITE}01100${BLUE}01${WHITE}101${BLUE}11000001110000
	echo -e ${BLUE}00010${RED}0110101${BLUE}100100111${WHITE}0110101110${BLUE}101111110${WHITE}001${BLUE}0${WHITE}010${BLUE}010110110${WHITE}11001${BLUE}11${WHITE}110${BLUE}01001110110101
	echo -e ${BLUE}11001${RED}1000111${BLUE}100100101${WHITE}0010011001${BLUE}00010110${WHITE}110${BLUE}011${WHITE}011${BLUE}11011000${WHITE}111${BLUE}00${WHITE}01100${BLUE}01010000000010
	echo -e ${BLUE}00000${RED}0011${BLUE}010111101001${WHITE}111${BLUE}1000${WHITE}001${BLUE}00100110${WHITE}010${BLUE}101${WHITE}110${BLUE}11010001${WHITE}000${BLUE}00${WHITE}00011${BLUE}10000101010011
	echo -e ${BLUE}00111${RED}00${BLUE}10010001010010${WHITE}011${BLUE}1101${WHITE}110${BLUE}1101011${WHITE}000${BLUE}10000${WHITE}111${BLUE}1101011${WHITE}101${BLUE}011${WHITE}0111${BLUE}11001111010001
	echo -e ${BLUE}00000100100000110101011111011111100101101010101100111010110111000101111111100001
	echo -e ${BLUE}01010010111110111101111001011011100111011110011010010101110011100110000010101000
	echo -e ${BLUE}00111110001101011011101001110001100100000011000010011011000001101100000100100011
	echo -e ${BLUE}10001111100010100101001101101001001001010101110001100110110110111011000011010001
	echo -e ${BLUE}01001111000110101000110011110001100001011000011110100001100000010000001001101001
	echo -e ${BLUE}01100000011000101010100111000101000100001011111101111010001111001110100001010011
	echo -e ${BLUE}00011001011111011101001000100100001011100111100101110111010101001001101011100000
	echo -e ${BLUE}01100001011010110110010010110100110100110010011011111100111000100000001101101111
	# Reset de kleur terug naar de default
	echo -e ${NC}

	# Heet de gebruiker welkom
	echo "Welkom bij het han4pi installatie programma."
	echo "Druk op enter om de installatie te starten."
	read null
	
	# Verander de hostname indien gewenst.
	echo $HOSTNAME > /etc/hostname
	
	# Verwijder oude han4pi map als die aanwezig is
	rm -rf "/home/$USERNAME/han4pi"
	
	# Download nieuwe han4pi files
	git clone https://github.com/Mastermindzh/han4pi.git "/home/$USERNAME/han4pi"
	
	#zet de rechten van de map goed
	chown -R "$USERNAME":"$USERNAME" "/home/$USERNAME/han4pi"
fi # End of skip

# Controlleer of de scriptversies gelijk zijn.
newver=$(bash "/home/$USERNAME/han4pi/install.sh"  -v)
if [ "$newver" -ne "$VERSION" ]
then
	clear
	echo -e ${RED}"Uw installatiescript is outdated."${NC}
	echo "We zullen het nieuwe script gebruiken, dat kunt u vinden in: /home/$USERNAME/han4pi"
	echo "Druk op enter om door te gaan..."
	read null
	bash "/home/$USERNAME/han4pi/install.sh" -s
fi

# Verwijder het installatie script uit de gebruikersmap.
	rm "/home/$USERNAME/han4pi/install.sh"

# Stel de han4pi wallpaper in
cp /home/"$USERNAME"/han4pi/bash/resources/wallpapers/wallpaper.jpg /usr/share/raspberrypi-artwork/han4pi.jpg
cp /home/"$USERNAME"/han4pi/bash/resources/desktop-items-0.conf /home/"$USERNAME"/.config/pcmanfm/LXDE-pi/desktop-items-0.conf 

# Kopieer de greeter naar een verborgen map
mkdir /home/"$USERNAME"/.han4pi
cp /home/"$USERNAME"/han4pi/bash/greeter.sh /home/"$USERNAME"/.han4pi/greeter.sh

# Zorg ervoor dat de greeter wordt uitgevoerd bij elke start van een terminal
echo "bash /home/$USERNAME/.han4pi/greeter.sh" >> "/home/$USERNAME/.bashrc"

# Zet de keyboard map op US, de standaard in Nederland.
setxkbmap us

# Maak de directory voor autostart apps en voeg daar lxterminal aan toe
mkdir /home/"$USERNAME"/.config/autostart
cp /home/"$USERNAME"/han4pi/bash/resources/start-terminal.desktop /home/"$USERNAME"/.config/autostart/

# Enable SPI
echo "dtparam=spi=on" >> /boot/config.txt

# Update en upgrade het systeem en installeer vervolgens de benodigde packages.
apt-get -y update && apt-get -y upgrade

# Installeer evt. benodigde software.
apt-get -y install python2.7-dev tightvncserver

# Installeer spidev
wget https://github.com/Gadgetoid/py-spidev/archive/master.zip
unzip master.zip
rm master.zip
cd py-spidev-master
sudo python setup.py install
cd ..

# Zet SSH aan (staat op de nieuwe pi's standaard uit)
systemctl enable ssh.service

# Zet tightvncserver op
clear
echo "De installatie van han4pi is geslaagd. U dient enkel nog een tightvnc wachtwoord op te zetten."
echo "Zodra u op enter drukt krijgt u tweemaal een wachtwoord invoervak, geef daar uw wachtwoord in."
echo "Na het invoeren van het wachtwoord wordt er gevraagd of u een 'view-only' wachtwoord wilt instellen. Geef hier een N in."
read null

vncserver :1

# Voeg tightvnc toe aan de opstartitems
cp "/home/$USERNAME/han4pi/bash/resources/tightvnc.desktop" "/home/$USERNAME/.config/autostart/"

# Voeg de games toe aan het menu
echo "cd /home/$USERNAME/\"han4pi/python/games/Catch the raspberry\"/ && python2 game.py" >> /opt/catch_the_raspberry.sh
cp "/home/$USERNAME/han4pi/python/games/Catch the raspberry/Images/icon.png" /usr/share/pixmaps/catch_the_raspberry.png
cp /home/"$USERNAME"/han4pi/bash/resources/catch_the_raspberry.desktop /usr/share/applications/Catch_the_raspberry.desktop
cp /home/"$USERNAME"/han4pi/bash/resources/catch_the_raspberry.desktop /home/"$USERNAME"/Desktop/Catch_the_raspberry.desktop

echo "cd /home/$USERNAME/\"han4pi/python/games/Catch the raspberry (controller)\"/ && python2 game.py" >> /opt/catch_the_raspberry_controller.sh
cp /home/"$USERNAME"/han4pi/bash/resources/catch_the_raspberry_controller.desktop /usr/share/applications/Catch_the_raspberry_controller.desktop
cp /home/"$USERNAME"/han4pi/bash/resources/catch_the_raspberry_controller.desktop /home/"$USERNAME"/Desktop/Catch_the_raspberry_controller.desktop
