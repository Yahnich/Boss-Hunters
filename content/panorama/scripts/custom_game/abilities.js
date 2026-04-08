// DEFAULT HUD INITIALIZATION
const mainHud = $.GetContextPanel().GetParent().GetParent().GetParent()
const DOTAHud = mainHud.FindChildTraverse("HUDElements")
const lowerHud = DOTAHud.FindChildTraverse("lower_hud")
var talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var levelUp = lowerHud.FindChildTraverse("level_stats_frame")

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

GameEvents.Subscribe("dota_player_display_ability_selection", DisplayAbilitySelection);
GameEvents.Subscribe("dota_player_remove_ability_selection", RemoveAbilitySelection);

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
		GameEvents.SendCustomGameEventToServer( "dota_player_ability_info_request", {pID : localID, entindex : lastRememberedHero} )	
	} else {
		PerformTalentLayout( );
	}
}

function RemoveAbilitySelection( eventData ){
	let abilitySelectionContainer = $("#AbilityIconRoot");
	abilitySelectionContainer.style.visibility = "collapse";
	abilitySelectionContainer.RemoveAndDeleteChildren()
}

function DisplayAbilitySelection( eventData ){
	if(eventData.PlayerID == localID ){
		let abilitySelectionContainer = $("#AbilityIconRoot");
		abilitySelectionContainer.style.visibility = "visible";
		abilitySelectionContainer.RemoveAndDeleteChildren()
		for (const id in eventData.abilityPool ){
			let abilityName = eventData.abilityPool[id]
			let abilityIcon = $.CreatePanel("DOTAAbilityImage", abilitySelectionContainer, "Ability_"+abilityName);
			abilityIcon.BLoadLayoutSnippet("AbilityIconContainer")
			abilityIcon.abilityname = abilityName
			$.Msg( abilityName )
			abilityIcon.SetPanelEvent("onmouseover", function(){
				$.Msg( abilityName )
				$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityIcon, abilityName, eventData.entindex );
				abilityIcon.SetHasClass("Highlighted", true)
			});
			abilityIcon.SetPanelEvent("onmouseout", function(){
				$.DispatchEvent("DOTAHideAbilityTooltip", abilityIcon);
				abilityIcon.SetHasClass("Highlighted", false)
			});
			abilityIcon.SetPanelEvent("onactivate", function(){
				$.DispatchEvent("DOTAHideAbilityTooltip", abilityIcon)
				GameEvents.SendCustomGameEventToServer( "send_player_selected_ability", { pID : localID, entindex : eventData.entindex, abilityName : abilityName, abilityToReplace : eventData.replacedAbility } ) 
			})
		}
	}
}