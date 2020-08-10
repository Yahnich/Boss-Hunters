// DEFAULT HUD INITIALIZATION
var mainHud = $.GetContextPanel().GetParent().GetParent().GetParent()
var shopHud = mainHud.FindChildTraverse("HUDElements").FindChildTraverse("shop")

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

var mainShop = shopHud.FindChildTraverse("GridMainShop");
var shopHeaders = mainShop.FindChildTraverse("GridShopHeaders").FindChildTraverse("GridMainTabs");
var basicTab = shopHeaders.FindChildTraverse("GridBasicsTab");
var upgradesTab = shopHeaders.FindChildTraverse("GridUpgradesTab");
var neutralsTab = shopHeaders.FindChildTraverse("GridNeutralsTab");
var upgradeContent = mainShop.FindChildTraverse("GridUpgradeItems");

(function(){
	mainShop.FindChildTraverse("GridShopHeaders").style.paddingRight = '0px';
	shopHud.FindChildTraverse("HeightLimiter").style.height = '850px';
	basicTab.style.width = '200px;';
	upgradesTab.style.width = '200px;';
	if (neutralsTab != null){
		neutralsTab.style.visibility = "collapse"
	}
	$.RegisterForUnhandledEvent( "DOTAShowAbilityInventoryItemTooltip", RequestInventoryRuneSlots );
	$.RegisterForUnhandledEvent( "DOTAShowAbilityShopItemTooltip", RequestShopRuneSlots );
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltip", RemoveRuneSlots );
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForEntityIndex", RemoveRuneSlots );
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForGuide", RemoveRuneSlots );
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForHero", RemoveRuneSlots );
	$.RegisterForUnhandledEvent( "DOTAShowAbilityTooltipForLevel", RemoveRuneSlots );
	GameEvents.Subscribe("bh_response_rune_data", WriteRuneInformation);
	GameEvents.Subscribe("bh_response_all_rune_data", WriteRuneInformationItem);
	
	var inventory = mainHud.FindChildTraverse("center_block").FindChildTraverse("inventory")
	for (i = 0; i <= 8; i++){
		var inventorySlot = inventory.FindChildTraverse("inventory_slot_"+i);
		var itemImage = inventorySlot.FindChildTraverse("ItemImage");
		var abilityButton = inventorySlot.FindChildTraverse("AbilityButton")
		itemImage.inventorySlot = i
		ApplyDraggableEvents( inventorySlot, i )
	}
})();

function ApplyDraggableEvents( abilityButton, inventoryIndex ){
	$.RegisterEventHandler( 'DragStart', abilityButton, function(info, info2){
		GameEvents.SendCustomGameEventToServer( "bh_request_all_rune_data", {entindex : Players.GetLocalPlayerPortraitUnit(),  inventory : inventoryIndex} )
	} );
	$.RegisterEventHandler( 'DragEnd', abilityButton, function(info, info2){
		 RemoveRuneSlotsItem()
	} );
}

function RemoveRuneSlotsItem(){
	var inventory = mainHud.FindChildTraverse("center_block").FindChildTraverse("inventory")
	for (i = 0; i <= 8; i++){
		var inventorySlot = inventory.FindChildTraverse("inventory_slot_"+i); 
		if (inventorySlot){
			var oldContainer = inventorySlot.FindChildTraverse("AbilityRuneSlotsContainer")
			if(oldContainer != null){
				oldContainer.style.visibility = "collapse"
				oldContainer.RemoveAndDeleteChildren()
				oldContainer.DeleteAsync(0)
			}
		}
	}
}


function WriteRuneInformationItem(eventData){
	for(var inventorySlot in eventData.itemData){
		CreateRuneSlotContainer( inventorySlot, eventData );
	}
}
function CreateRuneSlotContainer( inventorySlot, eventData ){
	var runePanelContainer = $.CreatePanel("Panel", $.GetContextPanel(), "AbilityRuneSlotsContainer");
	runePanelContainer.AddClass("RuneSlotContainerIcon");
	runePanelContainer.hittest = false;
	var runes = eventData.itemData[inventorySlot]
	for(var runeSlot in runes){
		CreateRuneSlotItem( runes[runeSlot], runePanelContainer, runeSlot, eventData.runeType )
	}
	var inventory = mainHud.FindChildTraverse("center_block").FindChildTraverse("inventory")
	var inventoryPanel = inventory.FindChildTraverse("inventory_slot_"+inventorySlot);
	runePanelContainer.inventorySlot = inventorySlot;
	runePanelContainer.runeInventorySlot = eventData.runeInventory;
	runePanelContainer.SetParent(inventoryPanel);
}

function CreateRuneSlotItem( runeData, runePanelContainer, runeSlot, potentialRune ){
	var runePanel = $.CreatePanel("DOTAItemImage", runePanelContainer, "AbilityRuneSlot"+runeSlot);
	runePanel.BLoadLayoutSnippet("RuneSlotImage");
	runePanel.SetScaling('stretch-to-fit-y-preserve-aspect');
	
	var runeLevel = runePanel.FindChildTraverse("RuneSlotLevelLabel")
	if (runeData.rune_level == undefined){
		runeLevel.style.visibility = "collapse";
	} else {
		runeLevel.text = runeData.rune_level;
		runeLevel.style.visibility = "visible";
	}
	
	if ( runeData.rune_type == undefined ) {
		runePanel.itemname = 'none'
	} else {
		runePanel.itemname = runeData.rune_type
	}
	runePanel.initialRune = runePanel.itemname
	runePanel.slot = runeSlot
	runePanel.potentialRune = potentialRune
	runePanel.SetDraggable( true )
	$.RegisterEventHandler( 'DragDrop', runePanel, function(info, info2, info3){
		GameEvents.SendCustomGameEventToServer( "bh_enter_rune_slot_request", {entindex : Players.GetLocalPlayerPortraitUnit(), inventorySlot : runePanelContainer.inventorySlot, runeItemSlot : runePanel.slot, runeInventorySlot : runePanelContainer.runeInventorySlot} )
	} );
	$.RegisterEventHandler( 'DragLeave', runePanel, function(info, info2){
		runePanel.SetHasClass( "Highlighted", false)
		runePanel.itemname = runePanel.initialRune
	} );
	$.RegisterEventHandler( 'DragEnter', runePanel, function(info, info2){
		runePanel.SetHasClass( "Highlighted", true)
		runePanel.itemname = runePanel.potentialRune
	} );
}

function RemoveRuneSlots(){
	var tooltipContent = mainHud.FindChildTraverse("Tooltips").FindChildTraverse("DOTAAbilityTooltip").FindChildTraverse("AbilityCoreDetails");

	var oldContainer = tooltipContent.FindChildTraverse("AbilityRuneSlotsContainer")
	if(oldContainer != null){
		oldContainer.style.visibility = "visible"
		oldContainer.RemoveAndDeleteChildren()
		oldContainer.DeleteAsync(0)
	}
}

function RequestInventoryRuneSlots(object, entityIndex, inventorySlot){
	RemoveRuneSlots()
	GameEvents.SendCustomGameEventToServer( "bh_request_rune_data", {entindex : entityIndex,  inventory : inventorySlot} )
}

function RequestShopRuneSlots(object, abilityName, guideName, entityIndex){
	RemoveRuneSlots()
	GameEvents.SendCustomGameEventToServer( "bh_request_rune_data", {pID : localID, entindex : entityIndex,  item : abilityName} )
}

function WriteRuneInformation(eventData){
	var DOTAtooltipContent = mainHud.FindChildTraverse("Tooltips").FindChildTraverse("DOTAAbilityTooltip")
	var tooltipContent = DOTAtooltipContent.FindChildTraverse("AbilityCoreDetails");
	var descriptions = tooltipContent.FindChildTraverse("AbilityExtraAttributes");
	
	RemoveRuneSlots()
	
	var runePanelContainer = $.CreatePanel("Panel", $.GetContextPanel(), "AbilityRuneSlotsContainer");
	runePanelContainer.AddClass("RuneSlotsContainer")
	
	for(var runeSlot in eventData.itemData){
		CreateRuneSlot( eventData.itemData[runeSlot], runePanelContainer, runeSlot )
	}
	
	runePanelContainer.SetParent(tooltipContent)
	tooltipContent.MoveChildBefore( runePanelContainer, descriptions );
}

function CreateRuneSlot( runeData, runePanelContainer, runeSlot ){
	var runePanel = $.CreatePanel("Panel", runePanelContainer, "AbilityRuneSlots"+runeSlot);
	runePanel.BLoadLayoutSnippet("RuneSlotContainerDescription");
	if ( runeData.rune_type == undefined ) {
		runePanel.FindChildTraverse("RuneSlotContainerImage").itemname = 'none'
		runePanel.FindChildTraverse("RuneSlotLabel").text = 'Empty Stone Slot'
	} else {
		runePanel.FindChildTraverse("RuneSlotContainerImage").itemname = runeData.rune_type
		
		var runePanelLabel = runePanel.FindChildTraverse("RuneSlotLabel")
		runePanelLabel.text = ''
		var height = 2
		if ( runeData.funcs["GetModifierBonusStats_Strength"] && runeData.funcs["GetModifierBonusStats_Agility"] && runeData.funcs["GetModifierBonusStats_Intellect"] ){
			runePanelLabel.SetDialogVariable( "number", runeData.funcs["GetModifierBonusStats_Strength"] );
			runePanelLabel.text =  runePanelLabel.text + $.Localize( "#RUNE_GetModifierBonusStats_All", runePanelLabel ) + '\n';
			var height = 13
			for(var func in runeData.funcs){
				if( func != "GetModifierBonusStats_Strength" && func != "GetModifierBonusStats_Agility" && func != "GetModifierBonusStats_Intellect"){
					runePanelLabel.SetDialogVariable( "number", runeData.funcs[func] );
					runePanelLabel.text =  runePanelLabel.text + $.Localize( "#RUNE_"+func, runePanelLabel ) + '\n';
					height += 13;
				}
			}
		} else {
			for(var func in runeData.funcs){
				runePanelLabel.SetDialogVariable( "number", runeData.funcs[func] );
				runePanelLabel.text =  runePanelLabel.text + $.Localize( "#RUNE_"+func, runePanelLabel ) + '\n';
				height += 13;
			}
		}
		runePanelLabel.style.height = height+'px';
	}
	
}