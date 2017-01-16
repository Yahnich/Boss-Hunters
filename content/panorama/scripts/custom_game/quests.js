GameEvents.Subscribe( "updateQuestLife", UpdateLives);
GameEvents.Subscribe( "updateQuestPrepTime", UpdateTimer);
GameEvents.Subscribe( "updateQuestRound", UpdateRound);
GameEvents.Subscribe( "sendDifficultyNotification", Initialize);

var tooltips = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("Tooltips").FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("Contents");
tooltips.style.width = "550px";
var tooltipLabels = tooltips.FindChildTraverse("AbilityDetails").FindChildTraverse("AbilityCoreDetails").FindChildTraverse("AbilityCosts");
var tooltipMana = tooltipLabels.FindChildTraverse("AbilityManaCost");
var tooltipCd = tooltipLabels.FindChildTraverse("AbilityCooldown");
tooltipLabels.style.paddingLeft = "5px";
tooltipLabels.style.paddingRight = "5px";
tooltipMana.style.fontSize = "15px";
tooltipCd.style.fontSize = "15px";
tooltipMana.style.marginLeft = "-55px";


function Initialize(arg){
	var diffLocToken =  $.Localize( ReplaceIntWithToken( arg.difficulty ) )

	$("#QuestDifficultyText").SetDialogVariable( "difficulty", diffLocToken );
	$("#QuestDifficultyText").text =  $.Localize( "#QuestDifficultyText", $("#QuestDifficultyText") );
	$("#QuestRoundText").visible =  false
	$("#QuestPrepText").visible = false
}

function UpdateLives(arg){
	$("#QuestLifeText").SetDialogVariableInt( "lives", arg.lives );
	$("#QuestLifeText").SetDialogVariableInt( "maxLives", arg.maxLives );
	$("#QuestLifeText").text =  $.Localize( "#QuestLifeText", $("#QuestLifeText") );
}

function UpdateTimer(arg){
	if( arg.prepTime > 0){	
		$("#QuestPrepText").visible =  true
		$("#QuestPrepText").SetDialogVariableInt( "prepTime", arg.prepTime );
		$("#QuestPrepText").text =  $.Localize( "#QuestPrepText", $("#QuestPrepText") );
	} else {
		$("#QuestPrepText").visible =  false
	}
}

function UpdateRound(arg){
	$("#QuestRoundText").visible =  true
	$("#QuestRoundText").SetDialogVariableInt( "roundNumber", arg.roundNumber );
	$("#QuestRoundText").SetDialogVariable( "roundText", $.Localize( arg.roundText ) );
	$("#QuestRoundText").text =  $.Localize( "#QuestRoundText", $("#QuestRoundText") );
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
	} else if(token == 5){
		return "#difficultyOutrageous"
	}
}