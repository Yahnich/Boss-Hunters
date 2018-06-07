var ID = Players.GetLocalPlayer();
var playerHero = Players.GetPlayerSelectedHero(ID);

var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
var healthBar = dotaHud.FindChildTraverse("HealthContainer");


var shieldLabel = $.CreatePanel( "Label", $.GetContextPanel(), "ShieldLabel");
shieldLabel.SetParent(healthBar);
shieldLabel.AddClass("HealthContainerShieldLabel");

GameEvents.Subscribe( "updateQuestLife", UpdateLives);
GameEvents.Subscribe( "updateQuestPrepTime", UpdateTimer);
GameEvents.Subscribe( "updateQuestRound", UpdateRound);
GameEvents.Subscribe( "heroLoadIn", Initialize);
GameEvents.Subscribe("dota_player_update_query_unit", UpdateCustomHud);
GameEvents.Subscribe( "round_has_ended", ToggleQuests);

GameEvents.Subscribe( "game_tools_ask_nettable_info", SendNetTableInfo);

(function()
{
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForEntityIndex", UpdateTooltipUI );
})();

function SendNetTableInfo()
{
	$.Msg( "-----------------------------------")
	$.Msg( CustomNetTables.GetAllTableValues( "game_info" ) )
	$.Msg( CustomNetTables.GetAllTableValues( "talents" ) )
	$.Msg( CustomNetTables.GetAllTableValues( "hero_properties" ) )
	$.Msg( CustomNetTables.GetAllTableValues( "stats_panel" ) )
}

function ToggleQuests(arg)
{
	var teamInfo = $("#QuestCenter")
	if(arg != null)
	{
		teamInfo.SetHasClass("SetHidden", false )
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
	} else {
		Game.EmitSound( "focus_change" )
		teamInfo.SetHasClass("SetHidden", !(teamInfo.BHasClass("SetHidden")) )
		if(teamInfo.BHasClass("SetHidden")){
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideRight.png")
		} else {
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
		}
	}
}

var DELAYED_COOLDOWN = {"omniknight_repel_ebf":true,
						"omniknight_guardian_angel_ebf":true,
						"life_stealer_rage":true,
						"winterw_ice_shell":true,
						"winterw_winters_kiss":true,
						"dark_seer_adamantium_shell":true,
						"death_prophet_weaken_silence":true,
						"morphling_cosmic_projection":true,
						"nyx_hide":true,
						"skinwalker_kickback_fortress":true,
						"windrunner_windrun":true,
						"necrolyte_sadist":true,
						"viper_nethertoxin":true,
						"night_stalker_crippling_fear_ebf":true,
						"weaver_shukuchi":true,
						"bristleback_yer_mum":true,
						"item_leechblade":true,
						"rattletrap_battery_assault_ebf":true,
						"rattletrap_reactive_shielding":true,
						"rattletrap_automated_artillery":true,
						"puck_phase_shift_ebf":true,
						"item_penitent_mail":true,
						"item_hurricane_blade":true,
						"axe_forced_shout":true,
						"skywrath_seal":true,
						"item_everbright_shield":true,
						"huskar_raging_berserker":true,
						"brewmaster_primal_avatar":true,
						"shadow_shaman_binding_shackles":true,
						"shadow_shaman_ignited_voodoo":true,
						"abaddon_borrowed_time_ebf":true,
						"item_wrathbearers_robes":true,
						"item_behemoths_heart":true,
						"centaur_champions_presence":true,
						"timbersaw_chak2":true,
						"timbersaw_chak":true,
						"dragon_knight_intervene":true,
						"dragon_knight_elder_dragon_berserker":true,
						"dark_willow_shadow_realm":true,
						"bloodseeker_blood_bath":true,
						"nyx_vendetta":true,
						}

function UpdateTooltipUI(id, abilityname, abilityid){
	var tooltips = dotaHud.FindChildTraverse("DOTAAbilityTooltip")
	if(tooltips != null){
		if( DELAYED_COOLDOWN != null && DELAYED_COOLDOWN[abilityname] != null){
			tooltips.FindChildTraverse("AbilityCooldown").style.backgroundImage = "url('file://{images}/custom_game/ability_delayed_cooldown_png.vtex')";
		} else {
			tooltips.FindChildTraverse("AbilityCooldown").style.backgroundImage = "url('s2r://panorama/images/status_icons/ability_cooldown_icon_psd.vtex')";
		}
		tooltips.FindChildTraverse("AbilityCosts").style.flowChildren = "down";
	}
}


function UpdateCustomHud(){
	// var index = Players.GetLocalPlayerPortraitUnit();
	// var bReset = true
	// var healthText = healthBar.FindChildTraverse("HealthLabel");
	// if(index != null && Entities.IsHero( index )){
		// var netTable = CustomNetTables.GetTableValue( "hero_properties", Entities.GetUnitName( index ) + index );
		// if (netTable != null){
			// if(netTable.barrier != null && netTable.barrier > 0){
				// var barrier = netTable.barrier;
				// shieldLabel.visible = true;
				// healthText.style.visibility = "collapse";
				// shieldLabel.text = healthText.text + " (+" + barrier + ")";
				// var pixelPct = Math.min(Math.max(barrier / Entities.GetMaxHealth(index) * 10, 2), 10);
				// healthBar.style.boxShadow = "inset #c0c0c0aa " + pixelPct + "px " + pixelPct + "px " + pixelPct + "px " + (pixelPct*2) + "px";
				// bReset = false
			// }
		// }
	// }
	// if(bReset){
		// shieldLabel.visible = false;
		// healthText.style.visibility = "visible";
		// healthBar.style.boxShadow = "inset #c0c0c000 5px 5px 5px 10px";
	// }
}


function Initialize(arg){
	var shop = dotaHud.FindChildTraverse("shop")    
	shop.RemoveClass("GuidesDisabled")
	var killCS = dotaHud.FindChildTraverse("quickstats");
	killCS.FindChildTraverse("QuickStatsContainer").style.visibility = "collapse";
	dotaHud.FindChildTraverse("GlyphScanContainer").style.visibility = "collapse";
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