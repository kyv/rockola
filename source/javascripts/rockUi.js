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
        var session = $.ajax({
                    'url' : 'session',
                    dataType: 'html',
                    async: false
        }).responseText;
	if (session === 'user') {
		$('a#upload').show();
		$('li#loginitem').hide();	
	}
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
				height:'auto',
				width:'auto',
				modal: true,
				buttons: {
				   "Enviar": function() {

					$('#formUploadFile').ajaxSubmit({
					dataType: 'json',
					success: function(json) { 
 			                                                               					   $.each(json, function(key, value){
					   if (json['type'] === 'error') {
						$('#uploadform').prepend('<span>favor de registrar</span>');
						return; 
					    }
					$('#formUploadFile').get(0).setAttribute('action', 'update');
					   $('#uploadform').prepend('<div id="audiodata"><span>Favor de corrigir los datos. Los etiquetas debe de ser descriptivas.</span><br/>'+value.title+' es de tipo '+ value.type +' y '+ value.size +' bits</div>');
					    $('#formUploadFile').append('<br/>Title: <input type="text" name="title" value="'+value.title+'"/> Artist: <input type="text" name="artist" value="'+value.artist+'"/></br>Tags: <input type="text" name="tags" value="'+value.tags+'"/> Etiquetas son libres :P</form></div>');

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
