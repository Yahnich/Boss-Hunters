GameEvents.Subscribe( "sendDifficultyNotification", DifficultyNotification);

var timer = Game.Time();
var timerOn = false;

function DifficultyNotification(arg){
	$("#NotificationCenter").SetHasClass( "NotificationsFadeIn", true );
	$("#NotificationCenter").visible = true;
	if(arg.compromised){
		var token1 = $.Localize( ReplaceIntWithToken( Math.floor(arg.difficulty) ) );
		var token2 = $.Localize( ReplaceIntWithToken( Math.ceil(arg.difficulty) ) );
		$("#NotificationCenterText").SetDialogVariable( "bottom", token1 );
		$("#NotificationCenterText").SetDialogVariable( "top", token2 );
		$("#NotificationCenterText").text =  $.Localize( "#NotificationCompromiseText", $("#NotificationCenterText") );
	} else{
		$("#NotificationCenterText").SetDialogVariable( "difficulty", $.Localize( ReplaceIntWithToken( Math.floor(arg.difficulty) ) ) );
		$("#NotificationCenterText").text = $.Localize( "#NotificationMajorityText", $("#NotificationCenterText") );
	}
}

function ReplaceIntWithToken(token){
	if(token == 1){
		return "#difficultyNormal"
	} else if(token == 2){
		return "#difficultyImpossible"
	} else if(token == 3){
		return "#difficultyPainful"
	} else if(token == 4){
		return "#difficultySadistic"
	}
}