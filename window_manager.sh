#!/bin/bash

# Version:    2.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/window-manager
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

#echo -n "Checking dependencies... "
for name in xfwm4 compiz xfconf-query yad
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

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

foo=$?

if [ "$foo" -eq 0 ]; then
	exit 0
elif [ "$foo" -eq 1 ]; then
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
Icon=xfce-display-mirror1
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

# Version:    2.0.0
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
