"use strict";

GameEvents.Subscribe( "boss_hunters_update_rounds", UpdateGameRound);
GameEvents.Subscribe( "boss_hunters_update_timer", UpdateReferenceTime);

const romanOne = "I"
const romanFive = "V"
const romanTen = "X"

function valueToRoman( value ){
	var romanNumeral = ""
	
	while(value >= 10){
		value = value - 10
		romanNumeral = romanNumeral + romanTen
	}
	if(value == 9){
		romanNumeral = romanNumeral + romanOne + romanTen
	};
	if( value == 5){
		romanNumeral = romanNumeral + romanFive
	}
	if( value == 4){

		romanNumeral = romanNumeral + romanOne + romanFive
	} else {
		while(value > 0){
			value = value - 1
			romanNumeral = romanNumeral + romanOne
		}
	}
	
	return romanNumeral
}

function UpdateGameRound(info){
	var gameRound = $("#GameRound")
	gameRound.text = "Round " + (info.rounds + 1) + " - " + $.Localize( "#event_" + info.round_name, gameRound ) + " " + valueToRoman( info.ascensions );
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