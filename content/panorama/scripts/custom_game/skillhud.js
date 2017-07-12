
// for (i = 0, i < abilityCount, i++){
	// var newChildPanel = $.CreatePanel( "Panel", parentPanel, "abilityname"+i );
	// newChildPanel.BLoadLayoutSnippet( "Ability" );
	// local icon = newChildPanel.FindChildrenWithClassTraverse("AbilityStyle")[0]
// }

// var abilityArray = new Array()



GameEvents.Subscribe( "checkNewHero", PickAbilities);

function PickAbilities(arg){
	$("#SkillSelectorMain").visible = true
	var parentPanel = $("#SkillSelectorContainer");
	var playerID = Game.GetLocalPlayerID();
	var heroID = Players.GetPlayerHeroEntityIndex( playerID );
	var skillList = CustomNetTables.GetTableValue( "skillList", Entities.GetUnitName( heroID ) + playerID );
	var inProgress = true;
	var i = 0;
	while(inProgress){
		if(skillList[i] != undefined){
			CreateAbilityPanel(parentPanel, skillList[i])
			i++;
		} else {
			inProgress = false;
		}
	}
}

function CreateAbilityPanel(parentPanel, abilityName){
	var newChildPanel = $.CreatePanel( "Button", parentPanel, abilityName);
	newChildPanel.BLoadLayoutSnippet( "Ability" );
	var icon = newChildPanel.FindChildrenWithClassTraverse("AbilityStyle")[0];
	var playerID = Game.GetLocalPlayerID();
	var heroID = Players.GetPlayerHeroEntityIndex( playerID );
	icon.abilityname = abilityName;
	newChildPanel.heroID = heroID
	newChildPanel.abilityname = abilityName
	newChildPanel.selected = newChildPanel.BHasClass("AbilitySelected")
	newChildPanel.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", newChildPanel, newChildPanel.abilityname, newChildPanel.heroID);
	}
	newChildPanel.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", newChildPanel);
	}
	newChildPanel.selectAbility = function(){
		GameEvents.SendCustomGameEventToServer( "hasSelectedAbility", {pID : playerID, ability : abilityName, selected : newChildPanel.selected} )
	}
	newChildPanel.processAbilityQuery = function(arg){
		if(arg.confirmed == 1){
			newChildPanel.SetHasClass("AbilitySelected", true)
		} else{
			newChildPanel.SetHasClass("AbilitySelected", false)
		}
	}
	GameEvents.Subscribe( "sendAbilityQuery"+abilityName, newChildPanel.processAbilityQuery);
	newChildPanel.SetPanelEvent("onmouseover", newChildPanel.showTooltip );
	newChildPanel.SetPanelEvent("onmouseout", newChildPanel.hideTooltip );
	newChildPanel.SetPanelEvent("onmouseactivate", newChildPanel.selectAbility);
}

function SendQueriedAbilities(){
	var playerID = Game.GetLocalPlayerID();
	GameEvents.SendCustomGameEventToServer( "initializeAbilities", {pID : playerID} )
}

GameEvents.Subscribe( "finishedAbilityQuery", deletePanels);

function deletePanels(){
	$("#SkillSelectorMain").visible = false
}