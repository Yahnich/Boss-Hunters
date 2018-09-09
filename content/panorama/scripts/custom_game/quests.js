var localID = Players.GetLocalPlayer();

var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
var healthBar = dotaHud.FindChildTraverse("HealthContainer");


var shieldLabel = $.CreatePanel( "Label", $.GetContextPanel(), "ShieldLabel");
shieldLabel.SetParent(healthBar);
shieldLabel.AddClass("HealthContainerShieldLabel");

GameEvents.Subscribe( "updateQuestLife", UpdateLives);
GameEvents.Subscribe( "updateQuestPrepTime", UpdateTimer);
GameEvents.Subscribe( "updateQuestRound", UpdateRound);
GameEvents.Subscribe( "updateQuestBoss", UpdateBoss);
GameEvents.Subscribe( "heroLoadIn", Initialize);
GameEvents.Subscribe("dota_player_update_query_unit", UpdateCustomHud);
GameEvents.Subscribe( "boss_hunters_event_has_ended", RemoveEventPopup);
GameEvents.Subscribe( "boss_hunters_event_has_started", ShowEventPopup);
GameEvents.Subscribe( "boss_hunters_prep_time_has_ended", RemoveRewardsPopup);
GameEvents.Subscribe( "boss_hunters_event_reward_given", ShowRewardsPopup);
GameEvents.Subscribe( "bh_move_camera_position", UpdateCameraPosition);

GameEvents.Subscribe( "bh_update_votes_prep_time", UpdatePrepVote);
GameEvents.Subscribe( "bh_start_prep_time", StartPrepVote);
GameEvents.Subscribe( "bh_end_prep_time", RemovePrepVotes);

GameEvents.Subscribe( "bh_start_ng_vote", StartNGVote)
Initialize()

var pressed = false

function StartNGVote(args)
{
	$("#QuestsAscensionVoteHolder").visible =  true
	
	var voteYes = $("#QuestAscensionVoteConfirmButton")
	var voteNo = $("#QuestAscensionVoteDeclineButton")
	var voteHolder = $("#QuestsAscensionVoteHolder")
	
	var ascDescription = $.Localize( "#ascension_Generic_Description", voteHolder );
	for(var i = 1; i <= Math.min(args.ascLevel,4); i++ ){
		ascDescription = ascDescription + " \n<br> " + $.Localize( "#ascension_" + i + "_Description", voteHolder );
	}
	voteHolder.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", voteHolder, ascDescription);});
	voteHolder.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", voteHolder);});
	
	$("#QuestAscensionVoteNoLabel").text =  "No: " + 0
	$("#QuestAscensionVoteYesLabel").text =  "Yes: " + 0
	
	voteYes.SetPanelEvent("onmouseover", function(){voteYes.SetHasClass("ButtonHover", true);});
	voteYes.SetPanelEvent("onmouseout", function(){voteYes.SetHasClass("ButtonHover", false);});
	voteYes.SetPanelEvent("onactivate", function(){ VoteNG(true) });
	
	voteNo.SetPanelEvent("onmouseover", function(){voteNo.SetHasClass("ButtonHover", true);});
	voteNo.SetPanelEvent("onmouseout", function(){voteNo.SetHasClass("ButtonHover", false);});
	voteNo.SetPanelEvent("onactivate", function(){ VoteNG(false) });
}

function VoteNG(bVote)
{
	$("#QuestsAscensionVoteHolder").visible = false;
	if(pressed == false){
		GameEvents.SendCustomGameEventToServer( "bh_player_voted_to_ng", {pID : localID, vote : bVote} )
		var voteYes = $("#QuestAscensionVoteConfirmButton")
		voteYes.SetPanelEvent("onmouseover", function(){});
		voteYes.SetPanelEvent("onmouseout", function(){});
		voteYes.SetPanelEvent("onactivate", function(){});
		pressed = true
	}
}

function UpdatePrepVote(args)
{
	if(args.ascension != null){
		$("#QuestAscensionVoteNoLabel").text =  "No: " + args.no
		$("#QuestAscensionVoteYesLabel").text =  "Yes: " + args.yes
		pressed = false
	} else {
		$("#QuestPrepVoteNoLabel").text =  "No: " + args.no
		$("#QuestPrepVoteYesLabel").text =  "Yes: " + args.yes
		pressed = false
	}
	
}

function VoteSkipPrep()
{
	$("#QuestsPrepVoteHolder").visible =  false
	if(pressed == false){
		GameEvents.SendCustomGameEventToServer( "bh_player_voted_to_skip", {pID : localID} )
		var voteYes = $("#QuestPrepVoteConfirmButton")
		voteYes.SetPanelEvent("onmouseover", function(){});
		voteYes.SetPanelEvent("onmouseout", function(){});
		voteYes.SetPanelEvent("onactivate", function(){});
		pressed = true
	}
}

function RemovePrepVotes(args)
{
	if(args.ascension != null){
		$("#QuestsAscensionVoteHolder").visible =  false
		var voteYes = $("#QuestAscensionVoteConfirmButton")
		voteYes.SetPanelEvent("onmouseover", function(){});
		voteYes.SetPanelEvent("onmouseout", function(){});
		voteYes.SetPanelEvent("onactivate", function(){});
		
		var voteNo = $("#QuestAscensionVoteDeclineButton")
		voteNo.SetPanelEvent("onmouseover", function(){});
		voteNo.SetPanelEvent("onmouseout", function(){});
		voteNo.SetPanelEvent("onactivate", function(){});
	} else {
		$("#QuestsPrepVoteHolder").visible =  false
		var voteYes = $("#QuestPrepVoteConfirmButton")
		voteYes.SetPanelEvent("onmouseover", function(){});
		voteYes.SetPanelEvent("onmouseout", function(){});
		voteYes.SetPanelEvent("onactivate", function(){});
	}
}


function StartPrepVote(args)
{
	$("#QuestsPrepVoteHolder").visible =  true
	
	var voteYes = $("#QuestPrepVoteConfirmButton")
	var voteLabel = $("#QuestsPrepVoteDescriptionLabel")
	voteLabel.text = "Skip preparation time?"
	$("#QuestPrepVoteNoLabel").text =  "No: " + 0
	$("#QuestPrepVoteYesLabel").text =  "Yes: " + 0
	voteYes.SetPanelEvent("onmouseover", function(){voteYes.SetHasClass("ButtonHover", true);});
	voteYes.SetPanelEvent("onmouseout", function(){voteYes.SetHasClass("ButtonHover", false);});
	voteYes.SetPanelEvent("onactivate", VoteSkipPrep);
}

function UpdateCameraPosition(args)
{
	GameUI.SetCameraTargetPosition(args.position, 0.3)
}


GameEvents.Subscribe( "game_tools_ask_nettable_info", SendNetTableInfo);

(function()
{
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForEntityIndex", UpdateTooltipUI );
	UpdateAccuracyTooltip()
})();

function UpdateAccuracyTooltip()
{
	var tooltips = dotaHud.FindChildTraverse("Tooltips");
	var uiTooltip = tooltips.FindChildTraverse("DOTAHUDDamageArmorTooltip");
	var currUnit = 	Players.GetLocalPlayerPortraitUnit()
	if(uiTooltip != null){
		var textLabel = uiTooltip.FindChildTraverse("PhysicalResistLabel");
		var valueLabel = uiTooltip.FindChildTraverse("PhysicalResist");
		textLabel.text = "Accuracy:";
		valueLabel.text = "0%";
		for (var i = 0; i < Entities.GetNumBuffs(currUnit); i++) {
			var buffID = Entities.GetBuff(currUnit, i)
			Buffs.GetName( currUnit, buffID )
			if (Buffs.GetName( currUnit, buffID ) == "modifier_accuracy_handler"){
				valueLabel.text = Buffs.GetStackCount( currUnit, buffID ) + "%";
			}
		}
		
	}
	GameUI.GetScreenWorldPosition
	
	
	var mPos = GameUI.GetCursorPosition()
    var gamePos = Game.ScreenXYToWorld(mPos[0], mPos[1])
    if ( gamePos !== null )
    {
		GameEvents.SendCustomGameEventToServer( "bh_update_mouse_position", {pID : localID, x : gamePos[0], y : gamePos[1]} )
    }
	
	$.Schedule( 0.33, UpdateAccuracyTooltip );
}

function SendNetTableInfo()
{
	$.Msg( "-----------------------------------")
	$.Msg( CustomNetTables.GetAllTableValues( "game_info" ) )
	$.Msg( CustomNetTables.GetAllTableValues( "talents" ) )
	$.Msg( CustomNetTables.GetAllTableValues( "hero_properties" ) )
	$.Msg( CustomNetTables.GetAllTableValues( "stats_panel" ) )
}

function ShowEventPopup(arg)
{
	var eventName = arg.event 
	var choiceCount = arg.choices
	$("#QuestsEventHolder").style.visibility = "visible";
	var holder = $("#QuestsEventChoices")
	for(var choice of holder.Children()){
		choice.style.visibility = "collapse"
		choice.RemoveAndDeleteChildren()
		choice.DeleteAsync(0)
	}
	
	var description = $("#QuestsEventDescription")
	var descriptionText = $("#QuestsEventDescriptionLabel")


	descriptionText.text = $.Localize( "#event_" + eventName + "_Description", descriptionText );
	
	for(var i = 1; i <= choiceCount; i++){
		CreateEventChoice(eventName, i)
	}
}

function ShowRewardsPopup(arg)
{
	var eventName = arg.event
	var choiceCount = arg.choices
	$("#QuestRewardsHolder").style.visibility = "visible";
	
	var reward = $("#QuestsRewardDescription")
	var rewardText = $("#QuestsRewardDescriptionLabel")
	
	var rewardButton = $("#QuestRewardConfirmButton")
	
	rewardButton.SetPanelEvent("onmouseover", function(){rewardButton.SetHasClass("ButtonHover", true);});
	rewardButton.SetPanelEvent("onmouseout", function(){rewardButton.SetHasClass("ButtonHover", false);});
	
	rewardText.text = $.Localize( "#event_" + eventName + "_Reward" + arg.reward, rewardText );
}

function RemoveEventPopup(arg)
{
	$("#QuestsEventHolder").style.visibility = "collapse";
}

function RemoveRewardsPopup(arg)
{
	$("#QuestRewardsHolder").style.visibility = "collapse";
}


function extractAllText(str){
	const re = /%(.*?)%/g;
	const result = [];
	var current;
	while (current = re.exec(str)) {
		result.push(current.pop());
	}

	return result[0]
}

function CreateEventChoice(eventName, choice)
{
	var holder = $("#QuestsEventChoices")
	var eventChoice = $.CreatePanel("Panel", holder, "QuestsEventChoice" + choice);
	eventChoice.BLoadLayoutSnippet("QuestsEventChoice");

	var eventChoiceText = eventChoice.FindChildTraverse("QuestsEventChoiceText")
	var eventText = $.Localize( "#event_" + eventName + "_option_" + choice );
	
	var prelim = extractAllText(eventText);
	var captured;
	if( ! (typeof prelim === "undefined") ){
		captured = $.Localize( "#" + extractAllText(eventText), eventChoiceText );
	}
	var capturedDescription = $.Localize( "#" + extractAllText(eventText) + "_Description", eventChoiceText );
	var replacement = eventText.replace(/%.*?%/, captured);
	
	eventChoiceText.html = true;
	eventChoiceText.text = replacement
	
	eventChoice.SetPanelEvent("onmouseover", function(){
		eventChoice.SetHasClass("ButtonHover", true);
		if(captured != null){
			$.DispatchEvent("DOTAShowTextTooltip", eventChoice, capturedDescription)
		}
	});
	eventChoice.SetPanelEvent("onmouseout", function(){eventChoice.SetHasClass("ButtonHover", false);
		if(captured != null){
			$.DispatchEvent("DOTAHideTextTooltip", eventChoice)
		}
	});
	eventChoice.SetPanelEvent("onactivate", function(){
		$("#QuestsEventHolder").style.visibility = "collapse";
		GameEvents.SendCustomGameEventToServer( "player_selected_event_choice_" + choice, {pID : localID} )
	} );
}

function ToggleQuests(arg)
{
	var teamInfo = $("#QuestCenter")
	if(arg != null)
	{
		teamInfo.SetHasClass("IsHidden", false )
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
	} else {
		Game.EmitSound( "focus_change" )
		teamInfo.SetHasClass("IsHidden", !(teamInfo.BHasClass("IsHidden")) )
		if(teamInfo.BHasClass("IsHidden")){
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideRight.png")
		} else {
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
		}
	}
}

var DELAYED_COOLDOWN = {"omniknight_repel_ebf":true,
						"omniknight_guardian_angel_ebf":true,
						"life_stealer_rage_bh":true,
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
	shop.FindChildTraverse("CommonItems").style.visibility = "collapse";
	var killCS = dotaHud.FindChildTraverse("quickstats");
	killCS.FindChildTraverse("QuickStatsContainer").style.visibility = "collapse";
	dotaHud.FindChildTraverse("GlyphScanContainer").style.visibility = "collapse";
	$("#QuestBossText").visible =  false
	$("#QuestRoundText").visible =  true
	$("#QuestsPrepVoteHolder").visible =  false
	
	var voteYes = $("#QuestPrepVoteConfirmButton")
	voteYes.SetPanelEvent("onmouseover", function(){voteYes.SetHasClass("ButtonHover", true);});
	voteYes.SetPanelEvent("onmouseout", function(){voteYes.SetHasClass("ButtonHover", false);});
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
	var ascension = "";
	if(arg.ascensionText != null){
		ascension = arg.ascensionText + ": "
	}
	$("#QuestRoundText").text = ascension + arg.roundText + " - " + $.Localize( "#event_" + arg.eventName, $("#QuestRoundText") )
}

function UpdateBoss(arg){
	$("#QuestBossText").visible =  true
	$.Msg( arg )
	$("#QuestBossText").text = "UPCOMING BOSS - " + $.Localize( "#event_" + arg.bossName, $("#QuestBossText") )
}