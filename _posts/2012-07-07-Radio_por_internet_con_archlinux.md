---
layout: post 
title: Transmitiendo con arch 
---

## Transmitiendo con archlinux, MPD, mpd-hora, darkice y pulseaudio

Damos 2 salidas a [[mpd|http://mpd.wikia.com/wiki/Music_Player_Daemon_Wiki]], uno a las bocinas y otro a [[darkice|http://code.google.com/p/darkice/]]. Eso nos permite monitorearlos por seperados, o inclusive bajar el volumen de un salida para unicamente dejar abierto la salida al internet. 

[[!img images/pulse-mpd.png alt="pulseaudio - mpd" size="426x266" class="left"]]

En el fondo [[ncmpc|http://mpd.wikia.com/wiki/Client:Ncmpc]] con nuestra barra de programacion y mas al fundo nuestro transmission como presentado en <http://radio.flujos.org>.

[[!img images/ncmpc-hora.png alt="ncmpc" class="left"]]

Utilizamos [[mpd-hora|https://github.com/kyv/mpd-hora]] para automatizar locucion de la hora. 

En el ultimo imagen vemos los niveles de grabacion, la entrada a darkice, lo cual es la mescla de microfono y musica reproducida.

[[!img images/pulse-darkice.png alt="pulseaudio - darkice" size="400x240" class="right"]]

###¿Como?

Asumimos que su sistema esta parecido a la nuestra, tiene un configuraion de pulseaudio en /etc/pulse/default, su darkice es version 1.1 o mayor y su configuracion si encuentra en /etc/darkice.cfg

#### Pulse


Creemos una salida virtual para en pulseaudio. Eso nos permite luego mandar cualcuier audio, o sea desde el microfono o de un reproductor, a darkice.

    load-module module-null-sink sink_name=darkice sink_properties="device.description='Darkice Sink'"
    load-module module-loopback source="alsa_input.pci-0000_00_1b.0.analog-stereo" sink="darkice"

En el ejemplo, la entrada del tarjeta de audio es 'alsa_input.pci-0000_00_1b.0.analog-stereo'. puede ser que varia en su sistema. averigua que entradas de audio estan disponibles con: 
  
    pactl list|grep alsa_input

####Darkice

En el seccion [input] de darkice tendremos algo parecido al siguente: 

    [input]
    device          = pulseaudio  
    sampleRate      = 22050
    bitsPerSample   = 16
    channel         = 2
    paSourceName = darkice.monitor

####MPD

Y ultimamente, si queremos dedicar una salida de mpd al radio por internet (para luego dedicar otra a sonido local, por ejemplo) agregamos un seccion 'output' al configuracion de mpd: 

    audio_output {
            type            "pulse"
            name            "MPD-Darkice"
            sink            "darkice" 
    }

[[!tag flujos mpd darkice pulseaudio]]
