---
layout: post 
title: Normalización de volumen 
---

# Normalización de volumen en Linux

<a href='http://tech.ebu.ch/loudness'><img src="http://tech.ebu.ch/webdav/site/tech/shared/images/logo_128_80px.jpg" class="right"/></a>

Hace unos años la industria de producción audiofonica lanzo un nuevo estándar con el objetivo de revolucionar el 'volumen de audio'. Producción audiofonica ha deteriorado sobre los años en un competición de amplitud. Esta competición ha sido reforzado, de alguna manera, tanto por la técnica que si ha utilizado para medir volumen, a decir, la medición de picos, como por la técnica que si ha ocupado para la normalización, a decir, el compresión.  

La problema de la volumen, entonces, tradicionalmente si ha resuelto con el sacrificio del rango dinámico. La [[propuesta del EBU r128|http://www.producción.com/articulo.php?a=1801]], ya adoptado por muchos fabricantes de mezcladora en la forma del *modo ebu*, es de adoptar un volumen estándar (-24db), cuantificación del volumen media y cuantificación del rango dinámica, permitiendo que ahora mezclamos en  base del volumen real de nuestro audio, y ya no en base te únicamente los picos.   

Todo eso viene mejor explicado en un [[vídeo de seminario en que fui prepuesta el nuevo estándar|http://www.youtube.com/watch?v=OF4nWo5zJ2I&feature=relmfu]]. 

## Linux

En cuanto que toca a Linux, hemos encontrado dos implementaciones. Uno es [[r128gain|http://www.hydrogenaudio.org/forums/index.php?showtopic=85978]], que es un implementación de [[blog/replaygain]]. Asi que funciona con cualcuier reproductor que entende los etiquetas de replaygain, pero en lugar de medir nivel pico utiliza el algoritmo descrito por el r128 y antecedentes para determinar la ganancia aplicado a cada audio. La otra es el [[ebumeter|http://kokkinizita.linuxaudio.org/linuxaudio/ebumeter-doc/quickguide.html]], para visualizar los adiós según el mismo algoritmo. 

[[!tag r128 replaygain normalización jackd ebumeter]]
