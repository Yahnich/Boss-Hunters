RELIC_TYPE_GENERIC = 1
RELIC_TYPE_CURSED = 2
RELIC_TYPE_UNIQUE = 3

var localID = Players.GetLocalPlayer()
CustomNetTables.SubscribeNetTableListener( "game_info", HandleRelicMenu )
CustomNetTables.SubscribeNetTableListener( "relics", UpdateRelicInventory )
GameEvents.Subscribe("dota_player_update_query_unit", UpdateRelicInventory);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdateRelicInventory);

var hasQueuedAction = false

function SelectRelic(type)
{
	if(hasQueuedAction == false)
	{
		var relicTable = CustomNetTables.GetTableValue( "game_info", "relic_drops");
		
		var playerRelics = relicTable[localID];
		var firstDrops = playerRelics[1];
		var relic = firstDrops[type]

		if( GameUI.IsAltDown() ){
			var relicName = $.Localize( relic )
			var relicDescr = $.Localize( relic + "_Description" )
			GameEvents.SendCustomGameEventToServer( "player_notify_relic", {pID : localID, text : "I will take following relic: " + relicName + " - " + relicDescr} )
		} else {
			hasQueuedAction = true
			Game.EmitSound( "Relics.SelectedRelic" )
			GameEvents.SendCustomGameEventToServer( "player_selected_relic", {pID : localID, relic : relic} )
		}
	}
}

function SkipRelics()
{
	if(hasQueuedAction == false)
	{
		if( GameUI.IsAltDown() ){
			GameEvents.SendCustomGameEventToServer( "player_notify_relic", {pID : localID, text : "I will skip my relic."} )
		} else {
			Game.EmitSound( "Button.Click" )
			hasQueuedAction = true
			GameEvents.SendCustomGameEventToServer( "player_skipped_relic", {pID : localID} )
		}
		
	}
}

function AddHover(panelID)
{
	var buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("ButtonHover", true)
	if(panelID == "SkipButton"){
		$.DispatchEvent("DOTAShowTextTooltip", buttonPanel, "Skipping a relic removes the relics from your pool and gives you 2 generic relics.")
	}
}

function RemoveHover(panelID)
{
	var buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("ButtonHover", false)
	if(panelID == "SkipButton"){
		$.DispatchEvent("DOTAHideTextTooltip", buttonPanel)
	}
}

$("#RelicRoot").SetHasClass("IsHidden", true)
HandleRelicMenu()
function HandleRelicMenu()
{
	var relicTable = CustomNetTables.GetTableValue( "game_info", "relic_drops")
	var playerRelics = relicTable[localID]
	var lastDrop = playerRelics[1]
	$.Msg(relicTable)
	if(lastDrop != null){
		var holder = $("#RelicChoiceHolder")
		for(var choice of holder.Children()){
			choice.style.visibility = "collapse"
			choice.RemoveAndDeleteChildren()
			choice.DeleteAsync(0)
		}
		for(var id in lastDrop){
			CreateRelicSelection(lastDrop[id], id)
		}
		Game.EmitSound( "Relics.GainedRelic" )
		$("#RelicRoot").SetHasClass("IsHidden", false)
	} else {
		$("#RelicRoot").SetHasClass("IsHidden", true)
	}
	hasQueuedAction = false
}

function CreateRelicSelection(relic, id)
{
	var holder = $("#RelicChoiceHolder")
	$.CreatePanel("Panel", holder, "").SetHasClass("VerticalSeperator", true)
	var relicChoice = $.CreatePanel("Panel", holder, "");
	relicChoice.BLoadLayoutSnippet("RelicChoiceContainer");
	var relicType = "";
	var selectButton = relicChoice.FindChildTraverse("SelectButtonSnippet");
	selectButton.SetPanelEvent("onactivate", function(){SelectRelic(id)})
	selectButton.SetPanelEvent("onmouseover", function(){selectButton.SetHasClass("ButtonHover", true)})
	selectButton.SetPanelEvent("onmouseout", function(){selectButton.SetHasClass("ButtonHover", false)})
	var typeLabel = relicChoice.FindChildTraverse("RelicTypeSnippet")
	if(relic.match(/unique/g) != null){
		relicType = "RELIC_TYPE_UNIQUE"
		typeLabel.style.color = "#ffd34a"
	} else if(relic.match(/cursed/g) != null){
		relicType = "RELIC_TYPE_CURSED"
		typeLabel.style.color = "#d80f0f"
	} else{
		relicType = "RELIC_TYPE_GENERIC"
		typeLabel.style.color = "#FFFFFF"
	}
	typeLabel.text = $.Localize( relicType )
	relicChoice.FindChildTraverse("RelicNameSnippet").text = $.Localize( relic )
	relicChoice.FindChildTraverse("SnippetRelicDescription").text = $.Localize( relic + "_Description" )
	
	$.CreatePanel("Panel", holder, "").SetHasClass("VerticalSeperator", true)
}

$("#RelicInventoryPanel").SetHasClass("IsHidden", true)

function OpenRelicInventory()
{
	var inventory = $("#RelicInventoryPanel")
	var invButton = $("#RelicInventoryButton")
	if(invButton.BHasClass("RelicButtonSelected") == false){
		UpdateRelicInventory()
	}
	inventory.SetHasClass("IsHidden", invButton.BHasClass("RelicButtonSelected") )
	invButton.SetHasClass("RelicButtonSelected", !invButton.BHasClass("RelicButtonSelected") )
}

function UpdateRelicInventory(){
	var inventory = $("#RelicInventoryPanel")
	for(var relic of inventory.Children()){
		relic.style.visibility = "collapse"
		relic.RemoveAndDeleteChildren()
		relic.DeleteAsync(0)
	}
	var selectedHero = Players.GetLocalPlayerPortraitUnit()
	if( !Entities.IsRealHero( selectedHero ) ){ selectedHero = Players.GetPlayerHeroEntityIndex( localID ) }
	var relicList = CustomNetTables.GetTableValue("relics", "relic_inventory_player_" + selectedHero)
	if(relicList != null){
		for(var name in relicList){
			if(name != 0){
				CreateRelicPanel(relicList[name])
			}
		}
	}
}

function CreateRelicPanel(name)
{
	var inventory = $("#RelicInventoryPanel")
	var relic = $.CreatePanel("Panel", inventory, "");
	relic.BLoadLayoutSnippet("RelicInventoryContainer")
	var relicName = $.Localize( name )
	var relicDescr = $.Localize( name + "_Description" )
	relic.FindChildTraverse("RelicLabel").text = relicName
	relic.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", relic, relicDescr)});
	relic.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", relic);});
	var ownerText = "I have "
	if( Players.GetLocalPlayerPortraitUnit() != Players.GetPlayerHeroEntityIndex( localID ) ){
		ownerText = $.Localize( Entities.GetUnitName( Players.GetLocalPlayerPortraitUnit() ) ) + " has "
	}
	relic.SetPanelEvent("onactivate", function(){ GameEvents.SendCustomGameEventToServer( "player_notify_relic", {pID : localID, text : ownerText + relicName + " - " + relicDescr} ) });
}

function ShowRelicTooltip()
{
	$.DispatchEvent("DOTAShowTextTooltip", $("#RelicInventoryButton"), "Relics are permanent bonuses that appear at the end of every 5th round.")
}

function HideRelicTooltip()
{
	$.DispatchEvent("DOTAHideTextTooltip", $("#RelicInventoryButton"))
}