# window-manager

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/window-manager
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di attivare i window manager Xfwm4 e Compiz

### INSTALLAZIONE
```sh
curl -o /tmp/window_manager.sh 'https://raw.githubusercontent.com/KeyofBlueS/window-manager/master/window_manager.sh'
sudo mkdir -p /opt/window-manager/
sudo mv /tmp/window_manager.sh /opt/window-manager/
sudo chown root:root /opt/window-manager/window_manager.sh
sudo chmod 755 /opt/window-manager/window_manager.sh
sudo chmod +x /opt/window-manager/window_manager.sh
sudo ln -s /opt/window-manager/window_manager.sh /usr/local/bin/window-manager
```

### UTILIZZO
Da terminale digitare:
```sh
$ window-manager
```
window-manager eseguirà uno switch fra i window manager Xfwm4 e Compiz.

Al primo avvio creerà un avviatore in Applicazioni > Impostazioni > window-manager toggle.
Questo avviatore aggiunto al pannello sarà dinamico, se Xfwm4 è attivo indicherà di attivare Compiz e viceversa.

È possibile utilizzare le seguenti opzioni:
```
--xfwm4	      Attiva il window manager Xfwm4

--compiz      Attiva il window manager Compiz

--toggle      Esegue uno switch fra i window manager Xfwm4 e Compiz

--help        Visualizza una descrizione ed opzioni di window-manager
```
