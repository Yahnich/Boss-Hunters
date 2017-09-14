
// for (i = 0, i < abilityCount, i++){
	// var newChildPanel = $.CreatePanel( "Panel", parentPanel, "abilityname"+i );
	// newChildPanel.BLoadLayoutSnippet( "Ability" );
	// local icon = newChildPanel.FindChildrenWithClassTraverse("AbilityStyle")[0]
// }

// var abilityArray = new Array()



GameEvents.Subscribe( "checkNewHero", PickAbilities);

function PickAbilities(arg){
	if($("#SkillSelectorMain").visible){
		
	}
	else {
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
	
}

function CreateAbilityPanel(parentPanel, abilityName){
	var newChildPanel = $.CreatePanel( "Button", parentPanel, abilityName);
	newChildPanel.BLoadLayoutSnippet( "Ability" );

	var icon = newChildPanel.FindChildrenWithClassTraverse("AbilityStyle")[0];
	var playerID = Game.GetLocalPlayerID();
	var heroID = Players.GetPlayerHeroEntityIndex( playerID );
	icon.abilityname = abilityName;
	newChildPanel.heroID = heroID;
	newChildPanel.abilityname = abilityName;
	newChildPanel.selected = newChildPanel.BHasClass("AbilitySelected");
	newChildPanel.SetDraggable(true);
	
	newChildPanel.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", newChildPanel, newChildPanel.abilityname, newChildPanel.heroID);
	}
	newChildPanel.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", newChildPanel);
	}
	newChildPanel.processAbilityQuery = function(arg){
		if(arg.confirmed == 1){
			newChildPanel.SetHasClass("AbilitySelected", true);
		} else{
			newChildPanel.SetHasClass("AbilitySelected", false);
		}
	}
	newChildPanel.OnDragStart = function( panelId, dragCallbacks ){
		var dummyPanel = $.CreatePanel( "DOTAAbilityImage", newChildPanel, abilityName+"_dummy" );
		dummyPanel.AddClass("AbilityIcon");
		dummyPanel.abilityname = abilityName;
		
		dragCallbacks.displayPanel = dummyPanel;
		dragCallbacks.offsetX = 0;
		dragCallbacks.offsetY = 0;
		
		return true;
	}
	newChildPanel.OnDragEnd = function( panelId, draggedPanel  ){
		draggedPanel.DeleteAsync( 0 );
		return true;
	}

	$.RegisterEventHandler( 'DragStart', newChildPanel, newChildPanel.OnDragStart );
	$.RegisterEventHandler( 'DragEnd', newChildPanel, newChildPanel.OnDragEnd );
	
	newChildPanel.SetPanelEvent("onmouseover", newChildPanel.showTooltip );
	newChildPanel.SetPanelEvent("onmouseout", newChildPanel.hideTooltip );
}



function RandomAbilities(){
	var playerID = Game.GetLocalPlayerID();
	var hero = Players.GetPlayerHeroEntityIndex( playerID )
	GameEvents.SendCustomGameEventToServer( "randomAbilities", {pID : playerID, heroID : hero } );
}


function SendQueriedAbilities(){
	var playerID = Game.GetLocalPlayerID();
	var allFilled = true;
	abilityList = []
	slotPosPanel = $("#SkillPositionContainer");
	var slots = slotPosPanel.Children()
	slots.forEach(function(item, index){
		if(item.abilityname == "no_ability" ){
			allFilled = false;
		} else {
			abilityList.push(item.abilityname)
		}
	})
	if (allFilled){GameEvents.SendCustomGameEventToServer( "initializeAbilities", {pID : playerID, abList : abilityList } );}
}

GameEvents.Subscribe( "finishedAbilityQuery", deletePanels);

function deletePanels(){
	$("#SkillSelectorMain").visible = false;
}

(function()
{
	var slotPosPanel = $("#SkillPositionContainer");
	var slots = slotPosPanel.Children()
	slots.forEach(function(item, index){
		
		item.OnDragEnter = function( a, draggedPanel )
		{
			item.AddClass( "AbilitySelected" );
			return true;
		}
		item.OnDragDrop = function( panelId, draggedPanel ){
			item.RemoveClass( "AbilitySelected" );
			var found = false;
			var sisterPanel;
			slots.forEach(function(item, index){
				if(item.abilityname == draggedPanel.abilityname){
					found = true;
					sisterPanel = item;
				}
			})
			if( found ){
				sisterPanel.abilityname = item.abilityname
			}
			item.abilityname = draggedPanel.abilityname
			item.SetDraggable(true)
			return true;
		}
		item.OnDragLeave = function( panelId, draggedPanel )
		{
			item.RemoveClass( "AbilitySelected" );
			return true;
		}
		
		item.OnDragStart = function( panelId, dragCallbacks ){
			if(item.abilityname != "no_ability" ){
				var dummyPanel = $.CreatePanel( "DOTAAbilityImage", item, item.abilityname+"_dummy" );
				dummyPanel.AddClass("AbilityIcon");
				dummyPanel.abilityname = item.abilityname;
				
				dragCallbacks.displayPanel = dummyPanel;
				dragCallbacks.offsetX = 0;
				dragCallbacks.offsetY = 0;
				
				return true;
			} else { return false; }
		}
		item.OnDragEnd = function( panelId, draggedPanel  ){
			draggedPanel.DeleteAsync( 0 );
			return true;
		}
		
		$.RegisterEventHandler( 'DragEnter', item, item.OnDragEnter );
		$.RegisterEventHandler( 'DragDrop', item, item.OnDragDrop );
		$.RegisterEventHandler( 'DragLeave', item, item.OnDragLeave );
		$.RegisterEventHandler( 'DragStart', item, item.OnDragStart );
		$.RegisterEventHandler( 'DragEnd', item, item.OnDragEnd );
	})
})();

