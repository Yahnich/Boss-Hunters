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

var mainHud = $.GetContextPanel().GetParent().GetParent().GetParent()
var shopHud = mainHud.FindChildTraverse("HUDElements").FindChildTraverse("shop_launcher_block")

var hasQueuedAction = false;
var firstRelicOfGame = true;

var globalRelicButton


(function(){
	var goldContainer = shopHud.FindChildTraverse("ShopCourierControls")
	goldContainer.style.flowChildren = 'right';
	var courier = goldContainer.FindChildTraverse("courier")
	courier.visible = false;
	var relicInventoryButton = $.CreatePanel("Panel", $.GetContextPanel(), "RelicInventoryButton");
	relicInventoryButton.BLoadLayoutSnippet("RelicInventoryButtonSnippet");
	relicInventoryButton.SetParent(goldContainer)
	relicInventoryButton.SetPanelEvent("onactivate", function(){OpenRelicInventory()})
	relicInventoryButton.SetPanelEvent("onmouseover", function(){
		relicInventoryButton.SetHasClass("ButtonHover", true)
		$.DispatchEvent("DOTAShowTextTooltip", relicInventoryButton, "Relics are permanent bonuses that can be gained by defeating bosses, elites or certain events.")
	})
	relicInventoryButton.SetPanelEvent("onmouseout", function(){
		relicInventoryButton.SetHasClass("ButtonHover", false)
		$.DispatchEvent("DOTAHideTextTooltip", relicInventoryButton)
	})
	$("#RelicRoot").SetHasClass("IsHidden", true);
	SendDropQuery();
	globalRelicButton = relicInventoryButton
	var inventory = $("#RelicInventoryPanel")
	inventory.SetHasClass("IsHidden", true )
})()

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

function HoldRelics()
{
	if(hasQueuedAction == false)
	{
		Game.EmitSound( "Button.Click" )
		$("#RelicRoot").SetHasClass("IsHidden", true)
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
	OpenRelicInventory(true)
}

function AddHover(panelID)
{
	var buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("ButtonHover", true)
	if(panelID == "SkipButton"){
		$.DispatchEvent("DOTAShowTextTooltip", buttonPanel, $.Localize("#relic_info_skip_relic") )
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
function UpdatePendingDrops(relicTable){
	var length = 0
	$("#RelicInventoryNotifyIdiots").style.visibility = "collapse";
	if( lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID ) ){
		if( relicTable.drops != null ){
			for ( relic in 	relicTable.drops ){
				length++
			}
			if( length == 0 ){
				$("#RelicDropNotification").style.visibility = "collapse";
			} else {
				$("#RelicDropNotification").style.visibility = "visible";
				$("#RelicDropLabel").text = length;
				if(firstRelicOfGame){
					$("#RelicInventoryNotifyIdiots").style.visibility = "visible";
					firstRelicOfGame = false;
				}
			}
		} else {
			$("#RelicDropNotification").style.visibility = "collapse";
		}
	} else {
		$("#RelicDropNotification").style.visibility = "collapse";
	}
}

function HandleRelicMenu(relicTable)
{
	if( lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID ) ){
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
}

function CreateRelicSelection(relic)
{
	var holder = $("#RelicChoiceHolder")
	var relicChoice = $.CreatePanel("Panel", holder, "RelicSelection_"+relic.name);
	relicChoice.BLoadLayoutSnippet("RelicChoiceContainer");
	
	relicChoice.SetPanelEvent("onactivate", function(){SelectRelic(relic.name)})
	relicChoice.SetPanelEvent("onmouseover", function(){
		relicChoice.SetHasClass("ButtonHover", true)
		$.DispatchEvent("DOTAShowTextTooltip", relicChoice, $.Localize( relic.name + "_Description" ) )
	})
	relicChoice.SetPanelEvent("onmouseout", function(){
		relicChoice.SetHasClass("ButtonHover", false)
		$.DispatchEvent("DOTAHideTextTooltip", relicChoice)
	})
	var typeLabel = relicChoice.FindChildTraverse("RelicNameSnippet")
	var relicIcon = relicChoice.FindChildTraverse("RelicIconSnippet")
	if(relic.rarity == "RARITY_EVENT"){
		typeLabel.style.color = "#2ce004"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_event.png")
	} else if(relic.rarity == "RARITY_LEGENDARY"){
		typeLabel.style.color = "#ff790c"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_legendary.png")
	} else if(relic.rarity == "RARITY_RARE"){
		typeLabel.style.color = "#a100ff"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_rare.png")
	} else if(relic.rarity == "RARITY_UNCOMMON"){
		typeLabel.style.color = "#0099ff"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_uncommon.png")
	} else if(relic.rarity == "RARITY_COMMON"){
		typeLabel.style.color = "#ffffff"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_common.png")
	}
	
	if( relic.cursed == 1 ){
		typeLabel.style.saturation = 0.6;
		typeLabel.style.brightness = 0.6;
		relicIcon.style.saturation = 0.6;
		relicIcon.style.brightness = 0.6;
	}
	typeLabel.text = $.Localize( relic.name )
}

var newRelics = {}
function OpenRelicInventory(forceClose)
{
	var inventory = $("#RelicInventoryPanel")
	if(globalRelicButton){
		if(globalRelicButton.BHasClass("RelicButtonSelected") == false){
			HoldRelics()
		}
		if( forceClose == true ){
			inventory.SetHasClass("IsHidden", true )
			globalRelicButton.SetHasClass("RelicButtonSelected", false )
		} else {
			if(inventory.Children()[0] != null){
				inventory.SetHasClass("IsHidden", globalRelicButton.BHasClass("RelicButtonSelected") )
				if (globalRelicButton.BHasClass("RelicButtonSelected") == true ){
					for(var relic of inventory.Children()){
						if( newRelics[relic.relic_entindex] != null ){
							newRelics[relic.relic_entindex] = false
							relic.style.border = '0px solid #00000000';
						}
					}
				}
			}
			globalRelicButton.SetHasClass("RelicButtonSelected", !globalRelicButton.BHasClass("RelicButtonSelected") )
		}
	}
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
			for(var relic in newRelics){
				if(table.relics[relic] == null){
					newRelics[relic] = null;
				}
			}
			for(var name in table.relics){
				if(name != 0){
					table.relics[name].relic_entindex = name
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
	var relicIcon = relicPanel.FindChildTraverse("RelicInventoryIconSnippet")
	relicLabel.text = relicName
	
	if(relic.rarity == "RARITY_EVENT"){
		relicLabel.style.color = "#2ce004"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_event.png")
	} else if(relic.rarity == "RARITY_LEGENDARY"){
		relicLabel.style.color = "#ff790c"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_legendary.png")
	} else if(relic.rarity == "RARITY_RARE"){
		relicLabel.style.color = "#a100ff"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_rare.png")
	} else if(relic.rarity == "RARITY_UNCOMMON"){
		relicLabel.style.color = "#0099ff"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_uncommon.png")
	} else if(relic.rarity == "RARITY_COMMON"){
		relicLabel.style.color = "#ffffff"
		relicIcon.SetImage("file://{images}/custom_game/relics/relic_rarity_common.png")
	}
	
	if( relic.cursed == 1 ){
		relicLabel.style.saturation = 0.8;
		relicLabel.style.brightness = 0.6;
	}
	if( newRelics[relic.relic_entindex] != false ){
		relicPanel.style.border = '1px solid #FFD700';
		newRelics[relic.relic_entindex] = true
	}
	relicPanel.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", relicPanel, relicDescr)});
	relicPanel.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", relicPanel);});
	var ownerText = "I have "
	if( Players.GetLocalPlayerPortraitUnit() != Players.GetPlayerHeroEntityIndex( localID ) ){
		ownerText = $.Localize( Entities.GetUnitName( Players.GetLocalPlayerPortraitUnit() ) ) + " has "
	}
	relicPanel.SetPanelEvent("onactivate", function(){ GameEvents.SendCustomGameEventToServer( "player_notify_relic", {pID : localID, text : ownerText + relicName + " - " + relicDescr} ) });
	
	relicPanel.relic_name = relic.name;
	relicPanel.relic_entindex = relic.relic_entindex;
}