/* Este objeto tendra el las funciones basicas para el manejo de 
 * la rockola.
 */
rockola = {
//variables y contenedores.
'player' : null,
'contenedor' : null,
'lista' : null,

'setTrack' : function (index){
	rockola.contenedor.find('li.activa').removeClass('activa');
	$(rockola.contenedor.find('li')[index]).addClass('activa');
	rockola.player.setPlaylist([rockola.lista_reproduccion[index]]);
},
'init' : function(content_query, player){
	rockola.contenedor=$(content_query);
	rockola.player=player;
}

}
