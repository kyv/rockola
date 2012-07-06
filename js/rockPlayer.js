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
var lista_reproduccion = null;

//Incio del document ready
$(function(){
	cargar_lista('ajax/lista_reproduccion.js');
	var rockPlayer = new jPlayerPlaylist({
		jPlayer: "#jquery_jplayer_N",
		cssSelectorAncestor: "#rockola"
	}, [
		{
			title:"Buffaro Bill vs Los Jinetes Ja",
			artist:"Los Jawuai Surfers",
			oga:"media/Los_Jawuai-BuFaLo_BiLl_Vs_LoS_jInEtEs_Ja.ogg"
			//mp3:"media/folie_atrois_ELECTRO.mp3"
		}
	], {
		playlistOptions: {
			enableRemoveControls: true,
			autoPlay:true
		},
		swfPath: "js",
		supplied: "webmv, ogv, m4v, oga, mp3"
	});
	
	$('ul.rockolites li a.oga').click(function() {
		rockPlayer.setPlaylist([
			{
				title:$(this).text(),
				artist:this.title,
				oga: $(this).hasClass('oga')? this.href: null
			}]);
			return false;
		});
	
	$('#playList a.mp3').click(function() {
		h2 = $(this).parent().parent().children('h2').text().split(' - ')
		rockPlayer.setPlaylist([
			{
				title:h2[1],
				artist:h2[0],
				mp3: this.href
			}]);
			return false;
		});
	$('#playList a.ogg').click(function() {
		h2 = $(this).parent().parent().children('h2').text().split(' - ')
		rockPlayer.setPlaylist([
			{
				title:h2[1],
				artist:h2[0],
				oga: this.href
			}]);
			return false;
		});
	
		
	$("#playlist-setPlaylist-audio-mix").click(function() {
		//rockPlayer.setPlaylist([]);
	});
	// The remove commands
	
	$("#remover").click(function() {
		rockPlayer.remove(1);//
		//rockPlayer.remove(-2);
		//rockPlayer.remove(0);
	});

	// The shuffle commands

	$("#revolver").click(function() {
		rockPlayer.shuffle();
		//rockPlayer.shuffle(false);
		//rockPlayer.shuffle(true);
	});

	// The select commands

	$("#select-2").click(function() {
		rockPlayer.select(-2);
		rockPlayer.play();
	});
	// The next/previous commands
	$("#playlist-next").click(function() {
		rockPlayer.next();
	});
	$("#playlist-previous").click(function() {
		rockPlayer.previous();
	});
	// The pause command
	$("#playlist-pause").click(function() {
		rockPlayer.pause();
	});

	// Changing the playlist options

	// Option: autoPlay
	$("#playlist-option-autoPlay-true").click(function() {
		rockPlayer.option("autoPlay", true);
	});
	$("#playlist-option-autoPlay-false").click(function() {
		rockPlayer.option("autoPlay", false);
	});

	// Option: enableRemoveControls
	$("#playlist-option-enableRemoveControls-true").click(function() {
		rockPlayer.option("enableRemoveControls", true);
	});
	$("#playlist-option-enableRemoveControls-false").click(function() {
		rockPlayer.option("enableRemoveControls", false);
	});

	// Option: displayTime

	$("#playlist-option-displayTime-0").click(function() {
		rockPlayer.option("displayTime", 0);
	});
	$("#playlist-option-displayTime-fast").click(function() {
		rockPlayer.option("displayTime", "fast");
	});
	$("#playlist-option-displayTime-slow").click(function() {
		rockPlayer.option("displayTime", "slow");
	});
	$("#playlist-option-displayTime-2000").click(function() {
		rockPlayer.option("displayTime", 2000);
	});

	// Option: addTime

	$("#playlist-option-addTime-0").click(function() {
		rockPlayer.option("addTime", 0);
	});
	$("#playlist-option-addTime-fast").click(function() {
		rockPlayer.option("addTime", "fast");
	});
	$("#playlist-option-addTime-slow").click(function() {
		rockPlayer.option("addTime", "slow");
	});
	$("#playlist-option-addTime-2000").click(function() {
		rockPlayer.option("addTime", 2000);
	});

	// Option: removeTime

	$("#playlist-option-removeTime-0").click(function() {
		rockPlayer.option("removeTime", 0);
	});
	$("#playlist-option-removeTime-fast").click(function() {
		rockPlayer.option("removeTime", "fast");
	});
	$("#playlist-option-removeTime-slow").click(function() {
		rockPlayer.option("removeTime", "slow");
	});
	$("#playlist-option-removeTime-2000").click(function() {
		rockPlayer.option("removeTime", 2000);
	});

	// Option: shuffleTime

	$("#playlist-option-shuffleTime-0").click(function() {
		rockPlayer.option("shuffleTime", 0);
	});
	$("#playlist-option-shuffleTime-fast").click(function() {
		rockPlayer.option("shuffleTime", "fast");
	});
	$("#playlist-option-shuffleTime-slow").click(function() {
		rockPlayer.option("shuffleTime", "slow");
	});
	$("#playlist-option-shuffleTime-2000").click(function() {
		rockPlayer.option("shuffleTime", 2000);
	});

});
/*
 * Funcion encargada de cargar la lista de resproduccion
 */
cargar_lista = function (lista_url){
	$.ajax({
		url: lista_url,
		async : false,
		dataType: 'json', 
		success: function(listaReproducccion) {
			lista_reproduccion=listaReproducccion;
			var lista_HTML = '';
			$.each(listaReproducccion, function(key, cancion) {
						lista_HTML += '<li><h2> '+ cancion.artist +' - <span>' +
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
