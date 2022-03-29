# Dokumentation

https://gluon.readthedocs.io/en/v2021.1.x/releases/v2021.1.1.html

Gluon Version, auf der die Freifunk Lüneburg Firmware basiert:

* v2021.1.1 

# Download der Firmware

* http://freifunk-lueneburg.de/firmware/

# Firmware selber bauen

1. Abhängigkeiten installieren

   sudo apt-get install git subversion build-essential gawk unzip libncurses5-dev zlib1g-dev libssl-de

2. Freifunk Lüneburg site clonen

   mkdir /opt/firmware/ 
   cd /opt/firmware/
   git clone https://github.com/FreifunkLueneburg/fflg-site.git

3. Firmware bauen

   cd /opt/firmware/fflg-site/
   ./doit.sh

   das Ergebnis ist in 
   /opt/firmware/fflg-site/gluon/output/images

4.  Build Verzeichnis säubern

   rm -rf /opt/firmware/fflg-site/gluon
