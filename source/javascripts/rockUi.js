/*!
 * Rockola site
 * http://rockola.flujos.org
 *
 * Copyright 2012, fitorec
 * Licensed under the GPL Version 2 license.
 * 
 * Descripción: En este archivo se pondran todas las funciones y logica
 *              necesarias para la ejecución de la interfaz de la Rockola
 * 
 * 
 */
$(function() {
$("<marquee>Rockalateca Virtual al Alcanze de tus Digitoz</marquee>").fadeIn(2000).appendTo('#col-centro h2.label');

	$( "#mainContent" ).tabs({
		select: function(e, ui) {
		var t = $(e.target);
		if(	ui.index == 2 ){
			$('#ventanaFlotante').dialog({
				title : 'Formulario de Contacto',
				height:340,
				width:500,
				modal: true,
				buttons: {
					"Enviar": function() {
						$( this ).dialog( "close" );
					},
					"Cancelar": function() {
						$( this ).dialog( "close" );
					}
				}
				});
				$('#ventanaFlotante').empty();
				$('<form action="" method="post">Nombre: <input type="text" name="nombre" value="nombre" id="formContacNombre" /><br >Correo: <input type="text" name="email" value="ejemplo@flujos.org" id="formContacEmail" /><br >Mensaje:<br /><textarea name="" cols="40" rows="5" id="formContactMsg" ></textarea>').fadeIn(2000).appendTo('#ventanaFlotante');
				//focus & blur para input#formContacEmail
				$('input#formContacEmail').focus(function (value){
					if( $(this).val() == 'ejemplo@flujos.org' )
						$(this).val('');
				}).blur(function (value){
					if( $(this).val() == '' )
						$(this).val('ejemplo@flujos.org');
				});
				//focus & blur para input#formContacNombre
				$('input#formContacNombre').focus(function (value){
					$(this).val('');
				}).blur(function (value){
					if( $(this).val() == '' )
						$(this).val('nombre');
				});
				return false;
		}else if(ui.index == 3 ){
			$('#ventanaFlotante').dialog({
				title : 'Subir tu propio audio',
				height:220,
				width:400,
				modal: true,
				buttons: {
				   "Enviar": function() {
					var div = $('<div>Para poder organizar la Rockolateca utilizamos etiquetas. Minimamente el audio debe de tener titulo, artista y genero. Pero las etiquetas son libres, por ejemplo el region de origin del audio tambien seria un etiqueta valida.');

					$('#formUploadFile').ajaxSubmit({
					dataType: 'json',
					success: function(json) { 
					   $.each(json, function(key, value){
					   div.append('<li>Nombre: '+ value.name +'</li><li>Tipo: '+ value.type +'</li><li>Bits: '+ value.size +'</li><form id=formUploadFile action="update" method="post"></br>Title: <input type="text" name="title" value="'+value.title+'"/></br>Artist: <input type="text" name="artist" value="'+value.artist+'"/></br>Tags: <input type="text" name="tags" value="'+value.tags+'"/><input type="hidden" name="id" value="'+value.id+'" ></form></div>');
                			   $('#uploadform').replaceWith(div); 

            				  });
					 }
            				 });
					},
					"Cancelar": function() {
						$( this ).dialog( "close" );
					}
				}
			});
		$('#ventanaFlotante').empty();
		$('<div id="uploadform"><form id=formUploadFile action="upload" method="post">Archivo: <input type="file" name="archivo" id="inputUploadFile" /></form></div>').fadeIn(1500).appendTo('#ventanaFlotante');
		return false;
	}
	return true;
	}});
///////////
$('#git-clone input').focus(function() {
	this.value = 'git clone flujos.org:web.git'
	this.select();
}).blur(function() {
		this.value='flujos.org:web.git';
});

$('#Formbuscar input').focus(function() {
	if( this.value =='Buscar')
		this.value='';
}).blur(function() {
	if( this.value=='')
		this.value='Buscar';
});

///////////7
});
