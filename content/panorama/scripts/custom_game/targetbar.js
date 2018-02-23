function tell_threat()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Tell_Threat", { pID: ID} );
}

GameEvents.Subscribe( "UpdateHealthBar", UpdateHealthBar);

function UpdateHealthBar(arg)
{
	if(GameUI.IsAltDown()){
		$("#targetPanelMain").style.marginTop = "20px";
	} else {
		$("#targetPanelMain").style.marginTop = "0px";
	}
	if(arg.closebar){
		$("#targetPanelMain").visible = false;
	} else {
		$("#targetPanelMain").visible = true;
		var nameMod = "_h"
		var difficulty = CustomNetTables.GetTableValue( "game_info", "difficulty" ).difficulty
		if(difficulty > 2){
			nameMod = "_vh"
		}
		if(arg.Name.match(/_h/g) != null && arg.Name.match(/_vh/g) != null){
			nameMod = ""
		}
		$("#bossNameLabel").text = $.Localize("#" + arg.Name + nameMod);
		$("#hpBarCurrentText").text = Entities.GetHealth( arg.entIndex ) + " / " + Entities.GetMaxHealth( arg.entIndex );
		var hpPct = Entities.GetHealth( arg.entIndex )/Entities.GetMaxHealth( arg.entIndex ) * 100
		$("#hpBarCurrent").style.clip = "rect( 0% ," + hpPct + "%" + ", 100% ,0% )";
		if(arg.elite != ""){
			$("#eliteSpecsText").visible = true;
			$("#eliteSpecsText").text = arg.elite;
		} else {
			$("#eliteSpecsText").visible = false;
			$("#eliteSpecsText").text = "lul";
		}
		var maxMana = Entities.GetMaxMana( arg.entIndex )
		if(maxMana > 0){
			$("#mpBarRoot").visible = true;
			$("#mpBarCurrentText").text = Entities.GetMana( arg.entIndex ) + " / " + maxMana;
			var manaPct = Entities.GetMana( arg.entIndex ) / maxMana * 100
			$("#mpBarCurrent").style.clip = "rect( 0% ," + manaPct + "%" + ", 100% ,0% )";
		} else {
			$("#mpBarRoot").visible = false;
		}
	}	
}

GameEvents.Subscribe( "Update_threat", update_threat);
function update_threat(arg)
{
	var threat = arg.threat.toFixed(1);
	$("#threatLabel").text = threat.toString();
	if (arg.aggro != null && arg.aggro == 1){
		$("#threatLabel").style.color = "#FF0000"
	} else if (arg.aggro != null && arg.aggro == 2){
		$("#threatLabel").style.color = "#FF8100"
	} else {
		$("#threatLabel").style.color= "#2FFF00"
	}
}

function tell_threat()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Tell_Threat", { pID: ID} );
}
