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
// GameEvents.Subscribe("dota_player_update_query_unit", UpdateCustomHud);
// GameEvents.Subscribe("dota_player_update_selected_unit", UpdateCustomHud);
GameEvents.Subscribe( "boss_hunters_event_has_ended", RemoveEventPopup);
GameEvents.Subscribe( "boss_hunters_event_has_started", ShowEventPopup);
GameEvents.Subscribe( "boss_hunters_prep_time_has_ended", RemoveRewardsPopup);
GameEvents.Subscribe( "boss_hunters_event_reward_given", ShowRewardsPopup);
GameEvents.Subscribe( "bh_move_camera_position", UpdateCameraPosition);

GameEvents.Subscribe( "bh_update_votes_prep_time", UpdatePrepVote);
GameEvents.Subscribe( "bh_start_prep_time", StartPrepVote);
GameEvents.Subscribe( "bh_end_prep_time", RemovePrepVotes);

GameEvents.Subscribe( "bh_start_ng_vote", StartNGVote);
GameEvents.Subscribe( "bh_update_ng_vote", UpdateNGVote);
GameEvents.Subscribe( "bh_end_ng_vote", EndNGVote);
GameEvents.Subscribe("bh_show_error_message", DisplayErrorMessage);

Initialize()

var pressed = false
function UpdateNGVote( args ){
	$("#QuestAscensionVoteNoLabel").text =  "No: " + args.no
	$("#QuestAscensionVoteYesLabel").text =  "Yes: " + args.yes
}
function StartNGVote(args)
{
	$("#QuestsAscensionVoteHolder").style.visibility = "visible";
	
	var voteYes = $("#QuestAscensionVoteConfirmButton")
	var voteNo = $("#QuestAscensionVoteDeclineButton")
	var voteHolder = $("#QuestsAscensionVoteHolder")
	var ascensionDescription = $("#QuestAscensionDescriptionLabel")
	
	var ascDescription = $.Localize( "#ascension_Generic_Description", ascensionDescription );
	for(var i = 1; i <= Math.min(args.ascLevel,4); i++ ){
		ascDescription = ascDescription + " \n" + $.Localize( "#ascension_" + i + "_Description", ascensionDescription );
	}
	ascensionDescription.text = ascDescription
	
	$("#QuestAscensionVoteNoLabel").text =  "No: " + 0
	$("#QuestAscensionVoteYesLabel").text =  "Yes: " + 0
	
	voteYes.SetPanelEvent("onmouseover", function(){voteYes.SetHasClass("ButtonHover", true);});
	voteYes.SetPanelEvent("onmouseout", function(){voteYes.SetHasClass("ButtonHover", false);});
	voteYes.SetPanelEvent("onactivate", function(){ VoteNG(true) });
	
	voteNo.SetPanelEvent("onmouseover", function(){voteNo.SetHasClass("ButtonHover", true);});
	voteNo.SetPanelEvent("onmouseout", function(){voteNo.SetHasClass("ButtonHover", false);});
	voteNo.SetPanelEvent("onactivate", function(){ VoteNG(false) });
	
	pressed = false;
}

function EndNGVote(arg)
{
	$("#QuestsAscensionVoteHolder").style.visibility = "collapse";
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
	for(var eventID in args.votes){
		var eventCard = $.GetContextPanel().FindChildTraverse("EventCard" + eventID)
		if( eventCard != null ){
			var eventVotes = eventCard.FindChildTraverse("EventCardVotes")
			for(var vote of eventVotes.Children()){
				vote.style.visibility = "collapse"
				vote.RemoveAndDeleteChildren()
				vote.DeleteAsync(0)
			}
			var icons = 0
			for(vote in args.votes[eventID]){
				var voteIcon = $.CreatePanel("DOTAHeroImage", eventVotes, "EventCardVoteIcon"+vote);
				var heroEntindex = Players.GetPlayerHeroEntityIndex( parseInt(vote) )
				voteIcon.heroname = Entities.GetUnitName( heroEntindex )
				voteIcon.heroimagestyle = "icon";
				voteIcon.SetHasClass("EventCardVoteIcon", true)
				icons++;
			}
			if( icons == 0 ){
				var voteIcon = $.CreatePanel("DOTAHeroImage", eventVotes, "EventCardVoteIconNil");
				voteIcon.SetHasClass("EventCardVoteIcon", true)
				voteIcon.heroname = "npc_dota_hero_unknown";
				voteIcon.heroimagestyle = "icon";
			}
		}
	}
	
}

function RemovePrepVotes()
{
	var eventCards = $("#EventCards")
	for(let card of eventCards.Children()){
		card.AddClass("FadeOut")
		card.DeleteAsync(0.5)
	}
}

function HidePrepVotes()
{
	var eventCards = $("#EventCards")
	for(var card of eventCards.Children()){
		card.style.height = "fit-children";
		
		var cardImage = card.FindChildTraverse("EventCardHeaderCard")
		cardImage.style.visibility = "collapse"
		
		var cardBody = card.FindChildTraverse("EventCardBody")
		cardBody.style.height = "fit-children"
		
		var foeTitle = card.FindChildTraverse("EventCardFoesTitle")
		foeTitle.style.visibility = "collapse"
		
		var foeContainer = card.FindChildTraverse("EventCardFoes")
		foeContainer.style.visibility = "collapse"
		
		var voteLabel = card.FindChildTraverse("EventCardVotesModifiersLabels");
		voteLabel.style.visibility = "collapse"
		
		card.eventIsCollapsed = true
	}
}

function UnhidePrepVotes()
{
	var eventCards = $("#EventCards")
	for(var card of eventCards.Children()){
		card.style.height = "700px";
		
		var cardImage = card.FindChildTraverse("EventCardHeaderCard")
		cardImage.style.visibility = "visible"
		
		var cardBody = card.FindChildTraverse("EventCardBody")
		cardBody.style.height = "fill-parent-flow(1)"
		
		var foeTitle = card.FindChildTraverse("EventCardFoesTitle")
		foeTitle.style.visibility = "visible"
		
		var foeContainer = card.FindChildTraverse("EventCardFoes")
		foeContainer.style.visibility = "visible"
		
		var voteLabel = card.FindChildTraverse("EventCardVotesModifiersLabels");
		voteLabel.style.visibility = "visible"
		
		card.eventIsCollapsed = false
	}
}


function StartPrepVote(args)
{
	const DELAY_MULT = 0.35
	let delay = DELAY_MULT
	for(let eventChoice in args.events){
		CreateEventCard(args.events[eventChoice], eventChoice, delay)
		// $.Schedule( delay, function(){ CreateEventCard( args.events[eventChoice], eventChoice ) } )
		delay += DELAY_MULT
	}
}

EVENT_TYPE_COMBAT = 1
EVENT_TYPE_ELITE = 2
EVENT_TYPE_EVENT = 3
EVENT_TYPE_BOSS = 4

EVENT_REWARD_GOLD = 1
EVENT_REWARD_LIVES = 2
EVENT_REWARD_RELIC = 3

function CreateEventCard(eventInfo, eventID, delay)
{
	var eventCards = $("#EventCards")
	var eventCard = $.CreatePanel("Panel", eventCards, "EventCard"+eventID);
	eventCard.BLoadLayoutSnippet("EventCardContainer");
	eventCard.eventID = eventID;
	var eventCardHeaderImage = eventCard.FindChildTraverse("EventCardHeaderCard")
	var eventCardHeaderTitle = eventCard.FindChildTraverse("EventCardHeaderTitle")
	eventCardHeaderTitle.text = $.Localize( "#event_" + eventInfo.eventName, eventCardHeaderTitle );
	if( eventCardHeaderImage != null){
		eventCardHeaderImage.SetImage("file://{images}/custom_game/event_cards/"+eventInfo.eventName+".png")
	}
	var eventCardHeaderReward = eventCard.FindChildTraverse("EventCardHeaderReward")
	var rewardDescription = "None"
	$.Msg( eventInfo.reward )
	if(eventInfo.reward == EVENT_REWARD_GOLD){
		eventCardHeaderReward.style.backgroundImage = "url('s2r://panorama/images/hud/icon_gold_psd.vtex');"
		rewardDescription = $.Localize( "#EVENT_REWARD_GOLD_Description", eventCardHeaderReward );
	} else if(eventInfo.reward == EVENT_REWARD_LIVES){
		eventCardHeaderReward.style.backgroundImage = "url('file://{images}/custom_game/events/reward_type_lives_icon_png.png')"
		rewardDescription = $.Localize( "#EVENT_REWARD_LIVES_Description", eventCardHeaderReward );
	} else if(eventInfo.reward == EVENT_REWARD_RELIC){
		eventCardHeaderReward.style.backgroundImage = "url('s2r://panorama/images/plus/achievements/relics_icon_png.vtex');"
		rewardDescription = $.Localize( "#EVENT_REWARD_RELIC_Description", eventCardHeaderReward );
	}
	eventCardHeaderReward.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", eventCardHeaderReward, rewardDescription)});
	eventCardHeaderReward.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", eventCardHeaderReward)});
	
	var eventCardHeaderType = eventCard.FindChildTraverse("EventCardHeaderType") 
	var typeDescription = "None"
	if(eventInfo.eventType == EVENT_TYPE_COMBAT){
		eventCardHeaderType.style.backgroundImage = "url('file://{images}/custom_game/events/encounter_room_icon_png.png');"
		typeDescription = $.Localize( "#EVENT_TYPE_COMBAT_Description", eventCardHeaderType );
	} else if(eventInfo.eventType == EVENT_TYPE_ELITE){
		eventCardHeaderType.style.backgroundImage = "url('file://{images}/custom_game/events/encounter_room_elite_icon_png.png')"
		typeDescription = $.Localize( "#EVENT_TYPE_ELITE_Description", eventCardHeaderType );
	} else if(eventInfo.eventType == EVENT_TYPE_EVENT){
		eventCardHeaderType.style.backgroundImage = "url('file://{images}/custom_game/events/bonus_room_icon_png.png');"
		typeDescription = $.Localize( "#EVENT_TYPE_EVENT_Description", eventCardHeaderType );
	} else if(eventInfo.eventType == EVENT_TYPE_BOSS){
		eventCardHeaderType.style.backgroundImage = "url('file://{images}/custom_game/events/boss_room_icon_png.png');"
		typeDescription = $.Localize( "#EVENT_TYPE_BOSS_Description", eventCardHeaderType );
	}
	eventCardHeaderType.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", eventCardHeaderType, typeDescription)});
	eventCardHeaderType.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", eventCardHeaderType)});
	
	var foeContainer = eventCard.FindChildTraverse("EventCardFoes")
	for(var foe in eventInfo.foes){
		CreateFoeSlot(eventInfo.foes[foe], foe, foeContainer )
	}
	if(eventInfo.modifiers[1] != null){
		var modifierContainer = eventCard.FindChildTraverse("EventCardModifiers");
		for( var id in eventInfo.modifiers ){
			CreateFoeAbility(eventInfo.modifiers[id], id, modifierContainer)
		}
	} else {
		var modifierLabel = eventCard.FindChildTraverse("EventCardModifiersLabel");
		modifierLabel.visible = false;
	}
	var eventVotes = eventCard.FindChildTraverse("EventCardVotes")
	var voteIcon = $.CreatePanel("DOTAHeroImage", eventVotes, "EventCardVoteIconNil");
	voteIcon.SetHasClass("EventCardVoteIcon", true)
	voteIcon.heroname = "npc_dota_hero_unknown";
	voteIcon.heroimagestyle = "icon";
	
	eventCard.eventIsCollapsed = false
	eventCard.SetPanelEvent("onmouseover", function(){eventCard.SetHasClass("EventCardHighlighted", true)});
	eventCard.SetPanelEvent("onmouseout", function(){eventCard.SetHasClass("EventCardHighlighted", false)});
	eventCard.SetPanelEvent("onactivate", function(){
		if( eventCard.eventIsCollapsed ){
			if( GameUI.IsAltDown()){
				UnhidePrepVotes()
			} else {
				GameEvents.SendCustomGameEventToServer( "bh_player_voted_to_skip", {pID : localID, eventID : eventCard.eventID} )
			}
		} else {
			if( !GameUI.IsAltDown()){
				GameEvents.SendCustomGameEventToServer( "bh_player_voted_to_skip", {pID : localID, eventID : eventCard.eventID} )
			}
			HidePrepVotes()
		}
		
	});
	eventCard.style.transition = 'transform 0.5s ease-in-out ' + delay + 's, opacity 0.35s ease-in-out 0.0s;';
	eventCard.AddClass("FadeIn")
	
}

function CreateFoeSlot(foeData, count, foeContainer)
{
	if(foeData.amount == 0){return};
	var foeSlot = $.CreatePanel("Panel", foeContainer, "FoeInfo"+foeData.name);
	foeSlot.BLoadLayoutSnippet("EventCardFoeContainer");
	
	var display = foeSlot.FindChildTraverse("EventCardFoeDisplay");
	display.SetUnit(foeData.name, "default", false);
	
	var foeCount = foeSlot.FindChildTraverse("EventCardFoeDisplayCount");
	foeCount.text = foeData.amount;
	if(foeData.amount == -1){
		foeCount.text = "?";
	}
	
	var abilityContainer = foeSlot.FindChildTraverse("EventCardFoeAbilities");
	for(var id in foeData.abilities){
		var abilityName = foeData.abilities[id]
		CreateFoeAbility( abilityName, id, abilityContainer )
	} 
}

function CreateFoeAbility(abilityName, id, abilityContainer)
{
	if(abilityName == "" ){return true}
	var abilitySlot = $.CreatePanel("DOTAAbilityImage", abilityContainer, "FoeAbility"+id);
	abilitySlot.SetHasClass("EventCardFoeAbility", true)
	abilitySlot.abilityname = abilityName;
	abilitySlot.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowAbilityTooltip", abilitySlot, abilitySlot.abilityname);});
	abilitySlot.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideAbilityTooltip", abilitySlot);});
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
		textLabel.text = "Area Damage:";
		valueLabel.text = "0%";
		for (var i = 0; i < Entities.GetNumBuffs(currUnit); i++) {
			var buffID = Entities.GetBuff(currUnit, i)
			Buffs.GetName( currUnit, buffID )
			if (Buffs.GetName( currUnit, buffID ) == "modifier_area_dmg_handler"){
				valueLabel.text = Buffs.GetStackCount( currUnit, buffID ) + "%";
			}
		}
	}
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

function UpdateTooltipUI(id, abilityname, abilityid)
{
	var tooltips = dotaHud.FindChildTraverse("DOTAAbilityTooltip");
	if(tooltips != null)
	{
		// if( DELAYED_COOLDOWN != null && DELAYED_COOLDOWN[abilityname] != null){
			// tooltips.FindChildTraverse("AbilityCooldown").style.backgroundImage = "url('file://{images}/custom_game/ability_delayed_cooldown_png.vtex')";
		// } else {
			// tooltips.FindChildTraverse("AbilityCooldown").style.backgroundImage = "url('s2r://panorama/images/status_icons/ability_cooldown_icon_psd.vtex')";
		// }
		tooltips.FindChildTraverse("AbilityCosts").style.flowChildren = "down";
	}
}


function UpdateCustomHud(){
	if (vector_target_particle !== undefined){
		var currentSelected = Players.GetLocalPlayerPortraitUnit();
		if(currentSelected != vectorTargetUnit){
			GameUI.SelectUnit(vectorTargetUnit, false)
		}
	}
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
	// $("#QuestBossText").visible =  false
	// $("#QuestRoundText").visible =  true
}

// function CheckHeroVectorAbilities(){
	// var localUnit = Players.GetLocalPlayerPortraitUnit()
	// var localUnitID = Entities.GetPlayerOwnerID( localUnit )
	// if ( localUnitID == localID ){
		// for( var i = 0;i<6;i++){
			// var ability = Entities.GetAbility( localUnit, i)
			// var filteredBehavior = Abilities.GetBehavior( ability ) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
			// if(filteredBehavior == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING){
				// $.Msg( Abilities.IsMarkedAsDirty( ability ) )
				// $.Msg( "------------------------------" )
			// }
		// }
	// }
	// $.Schedule( 1, CheckHeroVectorAbilities );
// }

function UpdateLives(arg){
	// $("#QuestLifeText").SetDialogVariableInt( "lives", arg.lives );
	// $("#QuestLifeText").SetDialogVariableInt( "maxLives", arg.maxLives );
	// $("#QuestLifeText").text =  $.Localize( "#QuestLifeText", $("#QuestLifeText") );
}

function UpdateTimer(arg){
	// if( arg.prepTime > 0){	
		// $("#QuestPrepText").visible =  true
		// $("#QuestPrepText").SetDialogVariableInt( "prepTime", arg.prepTime );
		// $("#QuestPrepText").text =  $.Localize( "#QuestPrepText", $("#QuestPrepText") );
	// } else {
		// $("#QuestPrepText").visible =  false
	// }
}

function UpdateRound(arg){
	// $("#QuestRoundText").visible =  true
	// var ascension = "";
	// if(arg.ascensionText != null){
		// ascension = arg.ascensionText + ": "
	// }
	// $("#QuestRoundText").text = ascension + arg.roundText + " - " + $.Localize( "#event_" + arg.eventName, $("#QuestRoundText") )
}

function UpdateBoss(arg){
	// $("#QuestBossText").visible =  true
	// $("#QuestBossText").text = "UPCOMING BOSS - " + $.Localize( "#event_" + arg.bossName, $("#QuestBossText") )
}

var error = null;
function DisplayErrorMessage(event)
{
	if(error != null){
		HideError()
	}
	error = $.CreatePanel('DOTAErrorMsg', $.GetContextPanel(), 'customErrorMessage');
	error.AddClass('VisGroup_Top') 
	error.AddClass('PopOutEffect')
	error.SetHasClass("ShowErrorMsg", true)
	error.style.opacity = 1.0;
	var errorLabel = $.CreatePanel('Label', error, 'customErrorMessageLabel');
	errorLabel.style.marginTop = "4px;";
	errorLabel.style.horizontalAlign = "middle";
	errorLabel.style.color = "white";
	errorLabel.style.fontSize = "28px";
	if(event._token != null){
		errorLabel.SetDialogVariableInt( "number", event._token ); 
	}
	errorLabel.text = $.Localize(event._error, errorLabel)
	$.Schedule(1.5, HideError)
}

function HideError()
{
	if(error != null){
		error.DeleteAsync( 0 );
		error = null;
	}
}