RELIC_TYPE_GENERIC = 1
RELIC_TYPE_CURSED = 2
RELIC_TYPE_UNIQUE = 3

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

GameEvents.Subscribe( "dota_player_updated_relic_drops", HandleRelicMenu )
GameEvents.Subscribe( "dota_player_update_relic_inventory", UpdateRelicInventory )
GameEvents.Subscribe("dota_player_update_query_unit", SendRelicQuery);
GameEvents.Subscribe("dota_player_update_selected_unit", SendRelicQuery);

var hasQueuedAction = false

function SelectRelic(relic)
{
	if(hasQueuedAction == false)
	{
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

function SendRelicQuery(){
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if ( !Entities.IsRealHero( lastRememberedHero ) ){ 
		lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
	}
	GameEvents.SendCustomGameEventToServer( "dota_player_query_relic_inventory", {entindex : lastRememberedHero, playerID : localID} )
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
function HandleRelicMenu(relicTable)
{
	if(relicTable != null) {
		if(relicTable.playerID == localID){
			
		}
		var lastDrop = relicTable.drops[1]
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
	} else {
		$("#RelicRoot").SetHasClass("IsHidden", true)
	}
	hasQueuedAction = false
}

function CreateRelicSelection(relic)
{
	var holder = $("#RelicChoiceHolder")
	$.CreatePanel("Panel", holder, "").SetHasClass("VerticalSeperator", true)
	var relicChoice = $.CreatePanel("Panel", holder, "");
	relicChoice.BLoadLayoutSnippet("RelicChoiceContainer");
	var relicType = "";
	var selectButton = relicChoice.FindChildTraverse("SelectButtonSnippet");
	selectButton.SetPanelEvent("onactivate", function(){SelectRelic(relic)})
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
		SendRelicQuery()
	}
	inventory.SetHasClass("IsHidden", invButton.BHasClass("RelicButtonSelected") )
	invButton.SetHasClass("RelicButtonSelected", !invButton.BHasClass("RelicButtonSelected") )
}

function UpdateRelicInventory(table){
	var inventory = $("#RelicInventoryPanel")
	for(var relic of inventory.Children()){
		relic.style.visibility = "collapse"
		relic.RemoveAndDeleteChildren()
		relic.DeleteAsync(0)
	}
	var selectedHero = Players.GetLocalPlayerPortraitUnit()
	if( !Entities.IsRealHero( selectedHero ) ){ selectedHero = Players.GetPlayerHeroEntityIndex( localID ) }
	if(table != null && table.relics != null){
		for(var name in table.relics){
			if(name != 0){
				CreateRelicPanel(table.relics[name])
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