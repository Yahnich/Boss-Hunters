RELIC_TYPE_GENERIC = 1
RELIC_TYPE_CURSED = 2
RELIC_TYPE_UNIQUE = 3

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

GameEvents.Subscribe( "dota_player_updated_relic_drops", UpdatePendingDrops )
GameEvents.Subscribe( "dota_player_request_relic_drops", HandleRelicMenu )
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

function SendDropQuery(){
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if ( !Entities.IsRealHero( lastRememberedHero ) ){ 
		lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
	}
	if( lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID ) ){
		GameEvents.SendCustomGameEventToServer( "dota_player_query_relic_drops", {entindex : lastRememberedHero, playerID : localID} )
	}
}

function AddHover(panelID)
{
	var buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("ButtonHover", true)
	if(panelID == "SkipButton"){
		$.DispatchEvent("DOTAShowTextTooltip", buttonPanel, "Skipping a relic removes the skipped relics from your pool, preventing them from showing up again.")
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
SendDropQuery()

function UpdatePendingDrops(relicTable){
	var length = 0
	if( relicTable.drops != null ){
		for ( relic in 	relicTable.drops ){
			length++
		}
		if( length == 0 ){
			$("#RelicDropNotification").style.visibility = "collapse";
		} else {
			$("#RelicDropNotification").style.visibility = "visible";
			$("#RelicDropLabel").text = length;
		}
	} else {
		$("#RelicDropNotification").style.visibility = "collapse";
	}
}

function HandleRelicMenu(relicTable)
{
	if(relicTable != null && relicTable.drops != null) {
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
				CreateRelicSelection(lastDrop[id])
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
	
	var selectButton = relicChoice.FindChildTraverse("SelectButtonSnippet");
	selectButton.SetPanelEvent("onactivate", function(){SelectRelic(relic.name)})
	selectButton.SetPanelEvent("onmouseover", function(){selectButton.SetHasClass("ButtonHover", true)})
	selectButton.SetPanelEvent("onmouseout", function(){selectButton.SetHasClass("ButtonHover", false)})
	var typeLabel = relicChoice.FindChildTraverse("RelicNameSnippet")
	if(relic.rarity == "RARITY_EVENT"){
		typeLabel.style.color = "#2ce004"
	} else if(relic.rarity == "RARITY_LEGENDARY"){
		typeLabel.style.color = "#ff790c"
	} else if(relic.rarity == "RARITY_RARE"){
		typeLabel.style.color = "#a100ff"
	} else if(relic.rarity == "RARITY_UNCOMMON"){
		typeLabel.style.color = "#0099ff"
	} else if(relic.rarity == "RARITY_COMMON"){
		typeLabel.style.color = "#ffffff"
	}
	
	if( relic.cursed == 1 ){
		typeLabel.style.saturation = 0.6;
		typeLabel.style.brightness = 0.6;
	}
	typeLabel.text = $.Localize( relic.name )
	relicChoice.FindChildTraverse("SnippetRelicDescription").text = $.Localize( relic.name + "_Description" )
	
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
	var selectedHero = Players.GetLocalPlayerPortraitUnit()
	if( !Entities.IsRealHero( selectedHero ) ){ selectedHero = Players.GetPlayerHeroEntityIndex( localID ) }
	if(table.hero == selectedHero){
		var inventory = $("#RelicInventoryPanel")
		for(var relic of inventory.Children()){
			relic.style.visibility = "collapse"
			relic.RemoveAndDeleteChildren()
			relic.DeleteAsync(0)
		}
		
		if(table != null && table.relics != null){
			for(var name in table.relics){
				if(name != 0){
					CreateRelicPanel(table.relics[name])
				}
			}
		}
	}
}

function CreateRelicPanel(relic)
{
	var inventory = $("#RelicInventoryPanel")
	var relicPanel = $.CreatePanel("Panel", inventory, "");
	relicPanel.BLoadLayoutSnippet("RelicInventoryContainer")
	var relicName = $.Localize( relic.name )
	var relicDescr = $.Localize( relic.name + "_Description" )
	var relicLabel = relicPanel.FindChildTraverse("RelicLabel")
	relicLabel.text = relicName
	
	if(relic.rarity == "RARITY_EVENT"){
		relicLabel.style.color = "#2ce004"
	} else if(relic.rarity == "RARITY_LEGENDARY"){
		relicLabel.style.color = "#ff790c"
	} else if(relic.rarity == "RARITY_RARE"){
		relicLabel.style.color = "#a100ff"
	} else if(relic.rarity == "RARITY_UNCOMMON"){
		relicLabel.style.color = "#0099ff"
	} else if(relic.rarity == "RARITY_COMMON"){
		relicLabel.style.color = "#ffffff"
	}
	
	if( relic.cursed == 1 ){
		relicLabel.style.saturation = 0.8;
		relicLabel.style.brightness = 0.6;
	}
	
	relicPanel.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", relicPanel, relicDescr)});
	relicPanel.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", relicPanel);});
	var ownerText = "I have "
	if( Players.GetLocalPlayerPortraitUnit() != Players.GetPlayerHeroEntityIndex( localID ) ){
		ownerText = $.Localize( Entities.GetUnitName( Players.GetLocalPlayerPortraitUnit() ) ) + " has "
	}
	relicPanel.SetPanelEvent("onactivate", function(){ GameEvents.SendCustomGameEventToServer( "player_notify_relic", {pID : localID, text : ownerText + relicName + " - " + relicDescr} ) });
}

function ShowRelicTooltip()
{
	$.DispatchEvent("DOTAShowTextTooltip", $("#RelicInventoryButton"), "Relics are permanent bonuses that can be gained by defeating bosses, elites or certain events.")
}

function HideRelicTooltip()
{
	$.DispatchEvent("DOTAHideTextTooltip", $("#RelicInventoryButton"))
}