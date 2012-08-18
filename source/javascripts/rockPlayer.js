/*!
 * Rockola site
 * http://rockola.flujos.org
 *
 * Copyright 2012, fitorec
 * Licensed under the GPL Version 2 license.
 * 
 * Descripción: Logica necesaria para administrar el reproductor de musica la
 *              Rockola.
 * 
 */
//Incio del document ready
$(function(){
	cargar_lista('media');
	///////////////
	rockola.init('#playList ul',
		new jPlayerPlaylist({
				jPlayer: "#jquery_jplayer_N",
				cssSelectorAncestor: "#rockola"
			}, [], {
				playlistOptions: {
					enableRemoveControls: true,
					autoPlay:false
				},
				swfPath: "js",
				supplied: "webmv, ogv, m4v, oga, mp3"
	}));
           $.ajax({
           'url' : '/tags',
           dataType: 'json',
           success: function(json){
                $.each(json, function(key, value){
		    var li = $("<li>");
			$("<a>").text(key).attr({title:"See all pages tagged with " + key, href:"tags/" + key }).appendTo(li);

                    li.children().css("fontSize", (value / 10 < 1) ? value / 10 + 1 + "em": (value / 10 > 2) ? "2em" : value / 10 + "em");
                    li.appendTo('#tags');
              });
           }
        });

	//Cargamos el 1er audio en la lista de reproducción.
	$('ul#rockolites li a.oga').click(function() {
		rockola.player.setPlaylist([
			{
				title:$(this).text(),
				artist:this.title,
				oga: $(this).hasClass('oga')? this.href: null
			}]);
			return false;
		});
	// upload form
        $.ajax({
            'url' : '/icestat',
            dataType: 'json',
            success: function(json){
                $.each(json, function(key, value){
                    $("#rockolites").append('<li><a href="http://radio.flujos.org:8000'+value.mount+'" class="oga">'+value.title+'</a> <span>'+value.current+'</span> </li>');
                });
            }

        });

	$('#playList li').click(function() {
		rockola.setTrack( $(this).attr('id').match(/[0-9]+$/)  );
	});

	$('#playList a.ogg').click(function() {
		h2 = $(this).parent().parent().children('h2').text().split(' - ')
		rockola.player.setPlaylist([
			{
				title:h2[1],
				artist:h2[0],
				oga: this.href
			}]);
			return false;
		});
	
		
	$("#playlist-setPlaylist-audio-mix").click(function() {
		//rockola.player.setPlaylist([]);
	});
	// The remove commands
	
	$("#remover").click(function() {
		rockola.player.remove(1);//
		//rockola.player.remove(-2);
		//rockola.player.remove(0);
	});

	// The shuffle commands

	$("#revolver").click(function() {
		rockola.player.shuffle();
		//rockola.player.shuffle(false);
		//rockola.player.shuffle(true);
	});

	// The select commands

	$("#select-2").click(function() {
		rockola.player.select(-2);
		rockola.player.play();
	});
	// The next/previous commands
	$("#playlist-next").click(function() {
		rockola.player.next();
	});
	$("#playlist-previous").click(function() {
		rockola.player.previous();
	});
	// The pause command
	$("#playlist-pause").click(function() {
		rockola.player.pause();
	});

	// Changing the playlist options

	// Option: enableRemoveControls
	$("#playlist-option-enableRemoveControls-true").click(function() {
		rockola.player.option("enableRemoveControls", true);
	});
	$("#playlist-option-enableRemoveControls-false").click(function() {
		rockola.player.option("enableRemoveControls", false);
	});

	// Option: displayTime

	$("#playlist-option-displayTime-0").click(function() {
		rockola.player.option("displayTime", 0);
	});
	$("#playlist-option-displayTime-fast").click(function() {
		rockola.player.option("displayTime", "fast");
	});
	$("#playlist-option-displayTime-slow").click(function() {
		rockola.player.option("displayTime", "slow");
	});
	$("#playlist-option-displayTime-2000").click(function() {
		rockola.player.option("displayTime", 2000);
	});

	// Option: addTime

	$("#playlist-option-addTime-0").click(function() {
		rockola.player.option("addTime", 0);
	});
	$("#playlist-option-addTime-fast").click(function() {
		rockola.player.option("addTime", "fast");
	});
	$("#playlist-option-addTime-slow").click(function() {
		rockola.player.option("addTime", "slow");
	});
	$("#playlist-option-addTime-2000").click(function() {
		rockola.player.option("addTime", 2000);
	});

	// Option: removeTime

	$("#playlist-option-removeTime-0").click(function() {
		rockola.player.option("removeTime", 0);
	});
	$("#playlist-option-removeTime-fast").click(function() {
		rockola.player.option("removeTime", "fast");
	});
	$("#playlist-option-removeTime-slow").click(function() {
		rockola.player.option("removeTime", "slow");
	});
	$("#playlist-option-removeTime-2000").click(function() {
		rockola.player.option("removeTime", 2000);
	});

	// Option: shuffleTime

	$("#playlist-option-shuffleTime-0").click(function() {
		rockola.player.option("shuffleTime", 0);
	});
	$("#playlist-option-shuffleTime-fast").click(function() {
		rockola.player.option("shuffleTime", "fast");
	});
	$("#playlist-option-shuffleTime-slow").click(function() {
		rockola.player.option("shuffleTime", "slow");
	});
	$("#playlist-option-shuffleTime-2000").click(function() {
		rockola.player.option("shuffleTime", 2000);
	});
});
/*
 * Funcion encargada de cargar la lista de resproduccion
 */
// tag cloud

cargar_lista = function (lista_url){
	$.ajax({
		url: lista_url,
		async : false,
		dataType: 'json', 
		success: function(listaReproducccion) {
			rockola.lista_reproduccion=listaReproducccion;
			var lista_HTML = '';
			inicio=true
			$.each(listaReproducccion, function(key, cancion) {
				lista_HTML += '<li id="rockolaTrack'+key+'"><h2> '+ cancion.artist +' - <span>' +
					cancion.title + '</span></h2><p>'+cancion.duration+' ';
				if(cancion.mp3){
					lista_HTML += '<a href=' + cancion.mp3 + ' class="mp3">mp3</a>';
				}
				if(cancion.oga){
					lista_HTML += '<a href=' + cancion.oga + ' class="ogg">ogg</a>';
				}
				lista_HTML += '</p></li>'
			});
			//Agregamos en lista no ordenada(ul) los items y lo insertamos en 
			$('<ul/>',{html: lista_HTML}).appendTo('#playList');
		}
	}).error(function(){/** aqui se deberia de cargar una lista por defecto */});
}//fin función cargar_lista
