#!/bin/bash

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/window-manager
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

#echo -n "Checking dependencies... "
for name in xfwm4 compiz
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

mkdir -p $HOME/.status_files/
touch $HOME/.status_files/window_manager_status

export DESKTOPFILE=`grep -H -r "Exec=window-manager" $HOME/.config/xfce4/panel/*/*.desktop | cut -d: -f1`

wm_xfwm4(){
pgrep -x "xfwm4"
if [ $? = 0 ]; then
echo
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
pgrep -x "compiz"
if [ $? = 0 ]; then
echo
echo "@ Compiz già ATTIVO, non procedo"
else
killall -w emerald
killall -w compiz
compiz --replace &
#    sleep 3 && emerald --replace &
fi
compiz_desktopfile
}

wm_toggle(){
if cat $HOME/.status_files/window_manager_status |
  grep -xqFe "Compiz"
then
echo "@ Compiz è l'attuale Window Manager, procedo col cambiarlo in Xfwm4"
   wm_xfwm4
elif cat $HOME/.status_files/window_manager_status |
  grep -xqFe "Xfwm4"
then
echo "@ Xfwm4 è l'attuale Window Manager, procedo col cambiarlo in Compiz"
   wm_compiz
else
echo "@ In DUBBIO sullo stato del Window Manager, attivo Compiz"
   wm_compiz
fi
}

xfwm4_desktopfile(){
grep -H -r "Exec=window-manager" $HOME/.config/xfce4/panel/*/*.desktop
if [ $? = 0 ]; then
sh -c 'echo "Xfwm4"'
sh -c 'echo "Xfwm4" > $HOME/.status_files/window_manager_status'
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
else
echo
fi
desktopfile
}

compiz_desktopfile(){
grep -H -r "Exec=window-manager" $HOME/.config/xfce4/panel/*/*.desktop
if [ $? = 0 ]; then
sh -c 'echo "Compiz"'
sh -c 'echo "Compiz" > $HOME/.status_files/window_manager_status'
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
else
echo
fi
desktopfile
}

desktopfile(){
if [ -e $HOME/.local/share/applications/window-manager.desktop ]
then
exit 0
else
echo -e "\e[1;34m## Creating window-manager.desktop file\e[0m"
sh -c 'echo "
[Desktop Entry]
Name=window-manager toggle
Exec=window-manager
Icon=xfce-display-mirror
Terminal=false
Type=Application
StartupNotify=false
Categories=XFCE;GTK;Settings;DesktopSettings;X-XFCE-SettingsDialog;X-XFCE-PersonalSettings;
OnlyShowIn=XFCE;" > $HOME/.local/share/applications/window-manager.desktop'
exit 0
fi
}

givemehelp(){
echo "
# window-manager

# Version:    1.0.0
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

if [ "$1" = "--xfwm4" ]
then
   wm_xfwm4
elif [ "$1" = "--compiz" ]
then
   wm_compiz
elif [ "$1" = "--toggle" ]
then
   wm_toggle
else
   wm_toggle
fi
