"use strict";

GameEvents.Subscribe( "boss_hunters_update_rounds", UpdateGameRound);
GameEvents.Subscribe( "boss_hunters_update_timer", UpdateReferenceTime);

function UpdateGameRound(info){
	var gameRound = $("#GameRound")
	gameRound.text = "Round " + (info.rounds + 1) + " - " + $.Localize( "#event_" + info.round_name, gameRound );
}

var referenceTime = undefined
function UpdateReferenceTime(info){
	referenceTime = info.game_time
}
UpdateGameTimer();
function UpdateGameTimer(){
	var gameTime = $("#GameTimer")
	var time = Game.GetDOTATime( false, true )
	if( !GameUI.IsAltDown() ){
		if( referenceTime != undefined ){
			time = time - referenceTime
		}
	}
	
	time = Math.abs( time )
	const zeroPad = (num, places) => String(num).padStart(places, '0')
	
	var minutes = Math.trunc( time / 60 )
	var seconds = zeroPad(Math.trunc( time % 60 ), 2 )
	gameTime.text = minutes + ":" + seconds;
	$.Schedule( 0.1, UpdateGameTimer )
}