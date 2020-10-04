// DEFAULT HUD INITIALIZATION
var lowerHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud")
var talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var levelUp = lowerHud.FindChildTraverse("level_stats_frame")

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "collapse";




GameEvents.Subscribe("dota_player_gained_level", RequestNewPanelData);
GameEvents.Subscribe("dota_player_learned_ability", RequestNewPanelData);
GameEvents.Subscribe("dota_player_update_query_unit", CheckUnitChanged);
GameEvents.Subscribe("dota_player_update_selected_unit", CheckUnitChanged);
GameEvents.Subscribe("dota_player_talent_info_response", ProcessTalentResponse);
GameEvents.Subscribe("dota_player_talent_update_failure", ServerResponded);

if(lastRememberedHero != -1){
	RequestNewPanelData()
} 

var serverRequestInProgress = false

function ServerResponded(){
	hasQueuedAction = false;
	serverRequestInProgress = false;
}

function CheckUnitChanged( eventData ){
	hasQueuedAction = false
	if(lastRememberedHero != Players.GetLocalPlayerPortraitUnit()){
		RequestNewPanelData()
	}
}

function RequestNewPanelData( eventData ){
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if(eventData != null && eventData.hero_entindex != null && eventData.hero_entindex != lastRememberedHero){return}
	if( eventData != null && eventData.PlayerID != null && Players.GetPlayerHeroEntityIndex( eventData.PlayerID ) != lastRememberedHero){return}
	if( Entities.IsRealHero( lastRememberedHero ) && !serverRequestInProgress){
		serverRequestInProgress = true
		GameEvents.SendCustomGameEventToServer( "dota_player_talent_info_request", {pID : localID, entindex : lastRememberedHero} )	
	} else {
		PerformTalentLayout( );
	}
}

function AttemptPurchaseTalent(talentName, abilityName){
	$.Msg( hasQueuedAction )
	if(!hasQueuedAction)
	{
		hasQueuedAction = true
		Game.EmitSound( "Button.Click" )
		GameEvents.SendCustomGameEventToServer( "send_player_selected_unique", {pID : localID, entindex : lastRememberedHero,  talent : talentName, abilityName : abilityName} )
	}
}

function ProcessTalentResponse( panelData ){
	$.Schedule( 0, function(){ 
		if(lowerHud.FindChildTraverse("Ability0") != null){
			PerformTalentLayout(panelData) 
		} else {
			ProcessTalentResponse( panelData )
		}
	} )
}

function PerformTalentLayout( panelData ){
	serverRequestInProgress = false
	hasQueuedAction = false
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	var netTable
	if(panelData != null){
		netTable = panelData.response
	}
	for (i = 0; i <= 5; i++){
		var abilityCont = lowerHud.FindChildTraverse("Ability"+i)
		if(abilityCont != null){
			var abilityButton = abilityCont.FindChildTraverse("ButtonSize")
			var abilityImage = abilityCont.FindChildTraverse("AbilityImage")
			var abilityName = abilityImage.abilityname
			var abilityIndex = 	Entities.GetAbilityByName( lastRememberedHero, abilityName )
			var oldCont = abilityButton.FindChildTraverse("UniqueTalentContainer")
			if( oldCont != null ){
				oldCont.style.visibility = "collapse"
				oldCont.RemoveAndDeleteChildren()
				oldCont.DeleteAsync(0)
			}
			if(netTable != null && netTable.uniqueTalents != null && lastRememberedHero == panelData.entindex){
				var talentContainer = $.CreatePanel("Panel", $.GetContextPanel(), "UniqueTalentContainer");
				talentContainer.BLoadLayoutSnippet("TalentContainer")
				talentContainer.SetParent(abilityButton)
				
				var talentIndex = 1
				
				talentContainer.FindChildTraverse("UniqueTalent1").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent2").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent3").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent4").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent5").AddClass("IsHidden")
				for(var talent in netTable.uniqueTalents[abilityName]){
					var talentPhase = 0
					if ( netTable.uniqueTalents[abilityName][talent] == -1 ){
						talentPhase = 1
					} else if( Players.GetPlayerHeroEntityIndex( localID ) == lastRememberedHero && Abilities.GetLevel( abilityIndex ) > 0 && netTable.uniqueTalents[abilityName][talent] <= Entities.GetLevel( lastRememberedHero ) && panelData.talentPoints > 0){
						talentPhase = 2
					}
					AddTalentToAbilityButton(talentContainer, talent, talentIndex, talentPhase, abilityName )
					talentIndex++;
				}
			}
		}
	}
}

function AddTalentToAbilityButton( talentContainer, talentName, talentIndex, talentPhase, abilityName ){
	var talent = talentContainer.FindChildTraverse("UniqueTalent"+talentIndex)
	talent.RemoveClass("IsHidden")
	var regex = /\%(\S*?)\%/;
	if( talentPhase == 1 ){
		talent.AddClass("Learned")
		talent.SetPanelEvent("onactivate", function(){
			var talentText = $.Localize( "#DOTA_Tooltip_Ability_"+talentName, talent) + " - " + $.Localize( "#DOTA_Tooltip_Ability_"+talentName+"_Description", talent)
			var matched = regex.exec(talentText);
			while ( matched != null ){
				var talentEnt = Entities.GetAbilityByName( lastRememberedHero, talentName )
				var value = Abilities.GetLevelSpecialValueFor( talentEnt, matched[1], 1 )
				var talentText = talentText.replace(matched[0], value);
				var matched = regex.exec(talentText);
			}
			var infoText = "I have " + talentText;
			GameEvents.SendCustomGameEventToServer( "notify_selected_talent", {pID : localID, text : infoText} )
		})
	} else if ( talentPhase == 2 ) {
		talent.AddClass("LevelReady")
		talent.SetPanelEvent("onactivate", function(){
			$.DispatchEvent("DOTAHideAbilityTooltip", talent)
			if(!GameUI.IsAltDown()){
				talent.SetPanelEvent("onactivate", function(){})
				AttemptPurchaseTalent(talentName, abilityName)
			} else {
				var talentText = $.Localize( "#DOTA_Tooltip_Ability_"+talentName, talent) + " - " + $.Localize( "#DOTA_Tooltip_Ability_"+talentName+"_Description", talent)
				var matched = regex.exec(talentText);
				while ( matched != null ){
					var talentEnt = Entities.GetAbilityByName( lastRememberedHero, talentName )
					var value = Abilities.GetLevelSpecialValueFor( talentEnt, matched[1], 1 )
					var talentText = talentText.replace(matched[0], value);
					var matched = regex.exec(talentText);
				}
				var infoText = "I will take " + talentText
				GameEvents.SendCustomGameEventToServer( "notify_selected_talent", {pID : localID, text : infoText} )
			}} );
			
	} else {
		talent.SetPanelEvent("onactivate", function(){
			var talentText = $.Localize( "#DOTA_Tooltip_Ability_"+talentName, talent) + " - " + $.Localize( "#DOTA_Tooltip_Ability_"+talentName+"_Description", talent)
			var matched = regex.exec(talentText);
			while ( matched != null ){
				var talentEnt = Entities.GetAbilityByName( lastRememberedHero, talentName )
				var value = Abilities.GetLevelSpecialValueFor( talentEnt, matched[1], 1 )
				var talentText = talentText.replace(matched[0], value);
				var matched = regex.exec(talentText);
			}
			var infoText = "I will take " + talentText
			GameEvents.SendCustomGameEventToServer( "notify_selected_talent", {pID : localID, text : infoText} )
		})
	}
	talent.SetPanelEvent("onmouseover", function(){
			talent.AddClass("Highlighted")
			$.DispatchEvent("DOTAShowAbilityTooltip", talent, talentName)});
	talent.SetPanelEvent("onmouseout", function(){
			talent.RemoveClass("Highlighted")
			$.DispatchEvent("DOTAHideAbilityTooltip", talent);});
}