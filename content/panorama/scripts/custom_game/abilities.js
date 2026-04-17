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

GameEvents.Subscribe("dota_player_display_perk_selection", DisplayPerkSelection);
GameEvents.Subscribe("dota_player_remove_perk_selection", RemovePerkSelection);

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

function RemovePerkSelection( eventData ){
	let perkSelectionContainer = $("#PerksRoot");
	perkSelectionContainer.style.visibility = "collapse";
	perkSelectionContainer.RemoveAndDeleteChildren()
}

function DisplayPerkSelection( eventData ){
	$.Msg("triggered")
	if(eventData.PlayerID == localID ){
		let perkSelectionContainer = $("#PerksRoot");
		perkSelectionContainer.style.visibility = "visible";
		perkSelectionContainer.RemoveAndDeleteChildren()+9
		for (const id in eventData.perks ){
			let perkData = eventData.perks[id]
			let perkPanel = $.CreatePanel("Panel", perkSelectionContainer, "Perk_"+perkData.perkName);
			perkPanel.BLoadLayoutSnippet("PerkContainer")
			
			let perkTitleVar = "#DOTA_Tooltip_Perk_" + perkData.perkName
			let perkTitle = $.Localize(perkTitleVar)
			for (const key in eventData.perkBonuses ){
				perkPanel.SetDialogVariable( key, eventData.perkBonuses[key].trim() )
				$.Msg( key, eventData.perkBonuses[key].trim() )
			}
			let perkDescription = $.Localize( perkTitleVar + "_Description",  perkPanel )
			
			let abilityIcon = perkPanel.GetChild(0);
			let abilityName = Abilities.GetAbilityName(eventData.ability)
			abilityIcon.abilityname = abilityName
			let abilityLabel = perkPanel.GetChild(1);
			if( !eventData.major ){
				perkDescription = $.Localize("#DOTA_Tooltip_ability_" + abilityName + "_" + perkData.perkName)
				perkDescription = perkDescription.toLowerCase()
				perkDescription = perkDescription.replace(":", "")
				perkDescription = perkData.perkValue + " " + titleCase(perkDescription)
				abilityLabel.text = perkDescription 
			} else {
				abilityLabel.text = perkTitle
			}
			
			perkPanel.SetPanelEvent("onmouseover", function(){
				if(eventData.major){
					$.DispatchEvent( "DOTAShowTextTooltip", perkPanel, perkDescription );
				}
				perkPanel.SetHasClass("Highlighted", true)
			});
			perkPanel.SetPanelEvent("onmouseout", function(){
				$.DispatchEvent("DOTAHideTitleTextTooltip", perkPanel);
				perkPanel.SetHasClass("Highlighted", false)
			});
			let notLocalHero = Entities.GetPlayerOwnerID( lastRememberedHero ) != localID
			let baseText = "I"
			if( notLocalHero ) {
				baseText = "%%#" + Entities.GetUnitName( lastRememberedHero ) + '%%'
						   + ' > '
			}
			baseText += " will learn: "
			perkPanel.SetPanelEvent("onactivate", function(){
				$.Msg( "activated" )
				if(!GameUI.IsAltDown()){
					GameEvents.SendCustomGameEventToServer( "send_player_selected_perk", { pID : localID, entindex : eventData.entindex,  ability: eventData.ability, perkName : perkData.perkName, perkType : eventData.major} ) 
				} else {
					let perkText = baseText + perkTitle
								   + ' > '
								   + perkDescription
					if(!eventData.major){
						perkText = baseText + perkDescription
					}
					perkText += " (%%#DOTA_Tooltip_ability_" + abilityName + "%%)"
					GameEvents.SendCustomGameEventToServer( "server_dota_push_to_chat", {PlayerID : localID, textData : perkText, isTeam : true, abilityID : Entities.GetAbilityByName( lastRememberedHero, abilityName )} )
				}
			})
		}
	}
}

function titleCase(str) {
   var splitStr = str.toLowerCase().split(' ');
   for (var i = 0; i < splitStr.length; i++) {
       splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);     
   }
   return splitStr.join(' '); 
}
