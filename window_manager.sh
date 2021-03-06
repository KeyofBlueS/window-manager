#!/bin/bash

# Version:    2.0.6
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/window-manager
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# set to "true" to enable autoupdate of this script
UPDATE=true

if echo $UPDATE | grep -Eq '^(true|True|TRUE|si|NO|no)$'; then
echo -e "\e[1;34mControllo aggiornamenti per questo script...\e[0m"
if curl -s github.com > /dev/null; then
	SCRIPT_LINK="https://raw.githubusercontent.com/KeyofBlueS/window-manager/master/window_manager.sh"
	UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "$SCRIPT_LINK" 2> /dev/null | grep "# Version:" | head -n 1)"
	LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
	REPOSITORY_LINK="$(cat "${0}" | grep "# Repository:" | head -n 1)"
	if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
		echo -e "\e[1;32m
## Questo script risulta aggiornato alla versione upstream
\e[0m
"
	else
		echo -e "\e[1;33m-----------------------------------------------------------------------------------	
## ATTENZIONE: questo script non risulta aggiornato alla versione upstream, visita:
\e[1;32m$REPOSITORY_LINK

\e[1;33m$LOCAL_VERSION (locale)
\e[1;32m$UPSTREAM_VERSION (upstream)
\e[1;33m-----------------------------------------------------------------------------------

\e[1;35mPremi invio per aggiornare questo script o attendi 10 secondi per andare avanti normalmente
\e[1;31m## ATTENZIONE: eventuali modifiche effettuate a questo script verranno perse!!!
\e[0m
"
		if read -t 10 _e; then
			echo -e "\e[1;34m	Aggiorno questo script...\e[0m"
			if [[ -L "${0}" ]]; then
				scriptpath="$(readlink -f "${0}")"
			else
				scriptpath="${0}"
			fi
			if [ -z "${scriptfolder}" ]; then
				scriptfolder="${scriptpath}"
				if ! [[ "${scriptpath}" =~ ^/.*$ ]]; then
					if ! [[ "${scriptpath}" =~ ^.*/.*$ ]]; then
					scriptfolder="./"
					fi
				fi
				scriptfolder="${scriptfolder%/*}/"
				scriptname="${scriptpath##*/}"
			fi
			if timeout -s SIGTERM 15 curl -s -o /tmp/"${scriptname}" "$SCRIPT_LINK"; then
				if [[ -w "${scriptfolder}${scriptname}" ]] && [[ -w "${scriptfolder}" ]]; then
					mv /tmp/"${scriptname}" "${scriptfolder}"
					chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				elif which sudo > /dev/null 2>&1; then
					echo -e "\e[1;33mPer proseguire con l'aggiornamento occorre concedere i permessi di amministratore\e[0m"
					sudo mv /tmp/"${scriptname}" "${scriptfolder}"
					sudo chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				else
					echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
Permesso negato!
\e[0m"
				fi
			else
				echo -e "\e[1;31m	Errore durante il download!
\e[0m"
			fi
			LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
			if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
				echo -e "\e[1;34m	Fatto!
\e[0m"
				exec "${scriptfolder}${scriptname}"
			else
				echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
\e[0m"
			fi
		fi
	fi
fi
fi

#echo -n "Checking dependencies... "
for name in compiz xfconf-query xfwm4 yad
do
if which $name > /dev/null; then
	echo -n
else
	if echo $name | grep -xq "xfconf-query"; then
		name="xfconf"
	fi
	if [ -z "${missing}" ]; then
		missing="$name"
	else
		missing="$missing $name"
	fi
fi
done
if ! [ -z "${missing}" ]; then
	echo -e "\e[1;31mQuesto script dipende da \e[1;34m$missing\e[1;31m. Utilizza \e[1;34msudo apt-get install $missing
\e[1;31mInstalla le dipendenze necessarie e riavvia questo script.\e[0m"
	exit 1
fi

export DESKTOPFILE="$(grep -Hr "Exec=window-manager" $HOME/.config/xfce4/panel/*/*.desktop | cut -d: -f1)"

wm_xfwm4(){
if pgrep -x "xfwm4" > /dev/null; then
	echo "@ Xfwm4 già ATTIVO, non procedo"
else
	xfconf-query -c xfwm4 -p /general/workspace_count -s 4
	killall -w emerald
	killall -w compiz
	xfwm4 --replace --daemon
	xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s false
	xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s true
fi
xfwm4_desktopfile
}

wm_compiz(){
if pgrep -x "compiz" > /dev/null; then
	echo "@ Compiz già ATTIVO, non procedo"
else
	killall -w emerald
	killall -w compiz
	compiz --replace &
#	sleep 3 && emerald --replace &
fi
compiz_desktopfile
}

wm_toggle(){
if pgrep -x "compiz" > /dev/null; then
	echo "@ Compiz è l'attuale Window Manager, procedo col cambiarlo in Xfwm4"
	wm_xfwm4
elif pgrep -x "xfwm4" > /dev/null; then
	echo "@ Xfwm4 è l'attuale Window Manager, procedo col cambiarlo in Compiz"
	wm_compiz
else
#	echo "@ In DUBBIO sullo stato del Window Manager, attivo Compiz" && wm_compiz
	echo "@ In DUBBIO sullo stato del Window Manager, attivo Xfwm4" && wm_xfwm4
fi
}

wm_yad(){
if pgrep -x "compiz" > /dev/null; then
	WINDOWMANAGER=Xfwm4
elif pgrep -x "xfwm4" > /dev/null; then
	WINDOWMANAGER=Compiz
fi
pkill -15 -f "yad --title=Window Manager*"
yad --title="Window Manager" --text="Vuoi passare a $WINDOWMANAGER?" \
--center \
--window-icon "monitor" \
--image-on-top \
--image "monitor" \
--wrap \
--sticky \
--on-top \
--buttons-layout=center \
--button=gtk-no:0 \
--button=gtk-yes:1

choose=$?

if [ "$choose" -eq 0 ]; then
	exit 0
elif [ "$choose" -eq 1 ]; then
	wm_toggle
else
	exit 0
fi
}

xfwm4_desktopfile(){
if [ -e $DESKTOPFILE ]; then
	if cat $DESKTOPFILE | grep -q "Name=Compiz"; then
		echo -n
	else
		sh -c 'echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Compiz (Attiva effetti)
Comment=Attiva il window manager Compiz
Exec=window-manager
Icon=xfce-display-mirror
Path=
Terminal=false
StartupNotify=false" > $DESKTOPFILE'
	fi
else
	echo -n
fi
desktopfile
}

compiz_desktopfile(){
if [ -e $DESKTOPFILE ]; then
	if cat $DESKTOPFILE | grep -q "Name=Xfwm"; then
		echo -n
	else
		sh -c 'echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Xfwm (Disattiva effetti)
Comment=Attiva il window manager Xfwm4
Exec=window-manager
Icon=xfce-display-mirror
Path=
Terminal=false
StartupNotify=false" > $DESKTOPFILE'
	fi
else
	echo -n
fi
desktopfile
}

desktopfile(){
#echo -e "\e[1;34m## Creating window-manager.desktop file\e[0m"
if [ -e $HOME/.local/share/applications/window-manager.desktop ]; then
	echo # "exist"
else
	sh -c 'echo "
[Desktop Entry]
Name=window-manager toggle
Comment=Alterna i window manager Xfwm4 e Compiz
Exec=window-manager --yad
Icon=xfce-display-mirror
Terminal=false
Type=Application
StartupNotify=false
Categories=XFCE;GTK;System;Settings;DesktopSettings;X-XFCE-SettingsDialog;X-XFCE-PersonalSettings;
OnlyShowIn=XFCE;" > $HOME/.local/share/applications1/window-manager.desktop'
fi

#echo -e "\e[1;34m## Creating autostart window-manager.desktop file\e[0m"
if xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command | grep -q "xfwm"; then
	if cat $HOME/.config/autostart/window-manager.desktop | grep -q "xfwm"; then
		echo # "already ok"
	else
		sh -c 'echo "[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=window-manager
Exec=window-manager --xfwm4-desktopfile
Icon=xfce-display-mirror
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false" > $HOME/.config/autostart/window-manager.desktop'
	fi
elif xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command | grep -q "compiz"; then
	if cat $HOME/.config/autostart/window-manager.desktop | grep -q "compiz"; then
		echo # "already ok"
	else
		sh -c 'echo "[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=window-manager
Exec=window-manager --compiz-desktopfile
Icon=xfce-display-mirror
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false" > $HOME/.config/autostart/window-manager.desktop'
	fi
else
	echo # "it's not xfwm4"
fi
exit 0
}

givemehelp(){
echo "
# window-manager

# Version:    2.0.6
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/window-manager
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di attivare i window manager Xfwm4 e Compiz.

### UTILIZZO
Da terminale digitare:

$ window-manager

window-manager eseguirà uno switch fra i window manager Xfwm4 e Compiz.

Al primo avvio creerà un avviatore in Applicazioni > Impostazioni > window-manager toggle.
Questo avviatore aggiunto al pannello sarà dinamico, se Xfwm4 è attivo indicherà di attivare Compiz e viceversa.

È possibile utilizzare le seguenti opzioni:
--xfwm4	      Attiva il window manager Xfwm4

--compiz      Attiva il window manager Compiz

--toggle      Esegue uno switch fra i window manager Xfwm4 e Compiz

--help        Visualizza una descrizione ed opzioni di window-manager
"
exit 0
}

if [ "$1" = "--xfwm4" ]; then
	wm_xfwm4
elif [ "$1" = "--compiz" ]
then
	wm_compiz
elif [ "$1" = "--toggle" ]; then
	wm_toggle
elif [ "$1" = "--yad" ]; then
	wm_yad
elif [ "$1" = "--xfwm4-desktopfile" ]; then
	xfwm4_desktopfile
elif [ "$1" = "--compiz-desktopfile" ]; then
	compiz_desktopfile
elif [ "$1" = "--desktopfile" ]; then
	desktopfile
else
	wm_toggle
fi
