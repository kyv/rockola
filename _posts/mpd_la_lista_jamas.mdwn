# Lista de reproduccion que acaba jamas

Una forma sencilla de hacer que la lista de reproduccion no acaba es llamar a un script al momento en que nuestro lista de reproduccion tiene menos que 2 rolas. Con mpdcron, podemos utilizar el siguiente codigo en en nuestro ~/.mpdcron/hooks/player: 

    if \[[ $(mpc playlist|wc -l) < 2 ]] ; then
        mpd_random_add 1
        mpc play 	# lista vacia
    fi

El 'play' ayuda en el caso de una lista vacia, para dar un empujon al reproductor. Nuesra preferencia es mantener el codigo para la agregar las rolas aparte, eso nos permite agregar 3 canciones desde la linea de comandos.

    mpd_random_add 3

El codigo original si encuentra en el [[wiki de mpd|http://mpd.wikia.com/wiki/Hack:addrandom]], aqui ponemos nuestro refrito. En cualcuiera de las formas, pega el codigo en algun lugar en su $PATH, por ejemplo, */usr/local/bin*, y llamalo *mpd_random_add*: 

    #!/bin/bash
    # Agregar 'numero' de canciones aleatoriamente de la biblioteca. 
    USAGE="Usage: `basename $0` [numero]"
    [ ${#} -eq 0 ] && { echo -e "$USAGE" >&2; exit 1; }
    
    var0=0
    LIMIT=$1
    while [ "$var0" -lt "$LIMIT" ]
    do
     mpc listall | sed -n $[RANDOM % $(mpc stats | grep Songs | awk '{print $2}')+1]p | mpc add
     var0=`expr $var0 + 1` 
    done
    echo
    exit 0

y para ser completos o olvidamos hacerlo ejecutable: 

    chmod +x /usr/local/bin/mpd_random_add 

[[!tag mpdcron mpd hacks automatización]]
