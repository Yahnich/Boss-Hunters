RELIC_TYPE_GENERIC = 1
RELIC_TYPE_CURSED = 2
RELIC_TYPE_UNIQUE = 3

var localID = Players.GetLocalPlayer()
CustomNetTables.SubscribeNetTableListener( "game_info", HandleRelicMenu )
CustomNetTables.SubscribeNetTableListener( "relics", UpdateRelicInventory )

var hasQueuedAction = false

function SelectRelic(type)
{
	if(hasQueuedAction == false)
	{
		var relicTable = CustomNetTables.GetTableValue( "game_info", "relic_drops");
		var playerRelics = relicTable[localID];
		var firstDrops = playerRelics[1];
		var relic = firstDrops[type]
			// if(type == RELIC_TYPE_GENERIC){
				// relic = firstDrops[RELIC_TYPE_GENERIC]
			// } else if(type == RELIC_TYPE_CURSED){
				// relic = firstDrops[RELIC_TYPE_CURSED]
			// } else if(type == RELIC_TYPE_UNIQUE){
				// relic = firstDrops[RELIC_TYPE_UNIQUE]
			// }
		if( GameUI.IsAltDown() ){
			var relicName = $.Localize( "#DOTA_Tooltip_" + relic )
			var relicDescr = $.Localize( "#DOTA_Tooltip_" + relic + "_Description" )
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
		$.DispatchEvent("DOTAShowTextTooltip", buttonPanel, "Skipping a relic will grants a stacking 15% bonus chance of receiving a relic (25% base chance) next round.")
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

function HandleRelicMenu()
{
	var relicTable = CustomNetTables.GetTableValue( "game_info", "relic_drops")
	var playerRelics = relicTable[localID]
	var lastDrop = playerRelics[1]
	if(lastDrop != null){
		Game.EmitSound( "Relics.GainedRelic" )
		$("#RelicRoot").SetHasClass("IsHidden", false)
		var genericRelic = lastDrop[RELIC_TYPE_GENERIC]
		var cursedRelic = lastDrop[RELIC_TYPE_CURSED]
		var uniqueRelic = lastDrop[RELIC_TYPE_UNIQUE]
		
		var genericRelicName = $("#GenericRelicName");
		var genericRelicDescription = $("#GenericRelicDescription");
		genericRelicName.text = $.Localize( "#DOTA_Tooltip_" + genericRelic )
		genericRelicDescription.text = $.Localize( "#DOTA_Tooltip_" + genericRelic + "_Description" )
		
		var cursedRelicName = $("#CursedRelicName");
		var cursedRelicDescription = $("#CursedRelicDescription");
		cursedRelicName.text = $.Localize( "#DOTA_Tooltip_" + cursedRelic )
		cursedRelicDescription.text = $.Localize( "#DOTA_Tooltip_" + cursedRelic + "_Description" )
		
		var uniqueRelicName = $("#UniqueRelicName");
		var uniqueRelicDescription = $("#UniqueRelicDescription");
		uniqueRelicName.text = $.Localize( "#DOTA_Tooltip_" + uniqueRelic, uniqueRelicName )
		uniqueRelicDescription.text = $.Localize( "#DOTA_Tooltip_" + uniqueRelic + "_Description" )
	} else {
		$("#RelicRoot").SetHasClass("IsHidden", true)
	}
	hasQueuedAction = false
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
	var relicList = CustomNetTables.GetTableValue("relics", "relic_inventory_player_" + localID)
	if(relicList != null){
		for(var name in relicList){
			if(name != 0){
				CreateRelicPanel(name)
			}
		}
	}
}

function CreateRelicPanel(name)
{
	var inventory = $("#RelicInventoryPanel")
	var relic = $.CreatePanel("Panel", inventory, "");
	relic.BLoadLayoutSnippet("RelicInventoryContainer")
	relic.FindChildTraverse("RelicLabel").text = $.Localize( "DOTA_Tooltip_" + name )
	relic.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", relic, $.Localize( "DOTA_Tooltip_" + name + "_Description" ))});
	relic.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", relic);});
}

function ShowRelicTooltip()
{
	$.DispatchEvent("DOTAShowTextTooltip", $("#RelicInventoryButton"), "Relics are permanent bonuses that have a 25% chance of being found at the end of a round.")
}

function HideRelicTooltip()
{
	$.DispatchEvent("DOTAHideTextTooltip", $("#RelicInventoryButton"))
}