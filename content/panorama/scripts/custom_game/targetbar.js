function tell_threat()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Tell_Threat", { pID: ID} );
}

GameEvents.Subscribe( "UpdateHealthBar", UpdatedSpawns);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdatedSelection);
GameEvents.Subscribe("dota_player_update_query_unit", UpdatedSelection);
GameEvents.Subscribe("entity_hurt", UpdatedAttack);

var newestBoss 
var localID = Game.GetLocalPlayerID()
$("#targetPanelMain").visible = false;

function UpdatedSpawns(args)
{
	
}

function UpdatedSelection()
{
	var selectedBoss = Players.GetLocalPlayerPortraitUnit();
	$.Msg(Entities.GetUnitName( selectedBoss ))
	if (Entities.GetTeamNumber( selectedBoss ) != Players.GetTeam( localID )){ // target is an enemy
		newestBoss = selectedBoss;
	}
	UpdateHealthBar(newestBoss);
}

function UpdatedAttack(arg)
{
	var selectedBoss = Players.GetLocalPlayerPortraitUnit();
	if (arg.entindex_inflictor == 0 && arg.entindex_attacker == Players.GetPlayerHeroEntityIndex( localID )){ // auto-attack is dealt by player owned hero
		newestBoss = arg.entindex_killed;
	}
	UpdateHealthBar(newestBoss);
}

function UpdateHealthBar(unit)
{
	var sUnit = unit
	if(unit == null){sUnit = newestBoss}
	if(GameUI.IsAltDown()){
		$("#targetPanelMain").style.marginTop = "20px";
	} else {
		$("#targetPanelMain").style.marginTop = "0px";
	}
	if(sUnit == null){
		$("#targetPanelMain").visible = false;
	} else {
		$("#targetPanelMain").visible = true;
		var nameMod = "_h"
		var difficulty = CustomNetTables.GetTableValue( "game_info", "difficulty" ).difficulty
		if(difficulty > 2){
			nameMod = "_vh"
		}
		var unitName = 	Entities.GetUnitName( sUnit )
		if((unitName.match(/_h/g) != null || unitName.match(/_vh/g) != null)){
			nameMod = ""
		}
		$("#bossNameLabel").text = $.Localize("#" + unitName + nameMod);
		$("#hpBarCurrentText").text = Entities.GetHealth( sUnit ) + " / " + Entities.GetMaxHealth( sUnit );
		var hpPct = Entities.GetHealth( sUnit )/Entities.GetMaxHealth( sUnit ) * 100
		$("#hpBarCurrent").style.clip = "rect( 0% ," + hpPct + "%" + ", 100% ,0% )";
		
		var elite = ""
		for (var i = 0; i < Entities.GetAbilityCount( sUnit ); i++) {
			var abilityID = Entities.GetAbility( sUnit, i )
			var abilityName = 	Abilities.GetAbilityName( abilityID )
			if (abilityName.match(/elite_/g)){
				elite = elite + " " + $.Localize( "#DOTA_Tooltip_ability_" + abilityName )
			}
		}
		if(elite != ""){
			$("#eliteSpecsText").visible = true;
			$("#eliteSpecsText").text = elite;
		} else {
			$("#eliteSpecsText").visible = false;
		}
		var maxMana = Entities.GetMaxMana( sUnit )
		if(maxMana > 0){
			$("#mpBarRoot").visible = true;
			$("#mpBarCurrentText").text = Entities.GetMana( sUnit ) + " / " + maxMana;
			var manaPct = Entities.GetMana( sUnit ) / maxMana * 100
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
