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
	basicTab.GetChild( 0 ).text = 'ITEMS';
	upgradesTab.style.width = '200px;';
	if (neutralsTab != null){
		neutralsTab.style.visibility = "collapse"
	}
	upgradeContent.style.flowChildren = "down"; 
	var statsCont2 = $.CreatePanel("Panel", $.GetContextPanel(), "AttackDamageContainer");
	statsCont2.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont2.FindChildTraverse("StatUpgradeLabel").text = "ATTACK DAMAGE (+10)";
	statsCont2.FindChildTraverse("ValueLabelSnipper").text = "275";
	statsCont2.SetParent(upgradeContent)
	
	var statsCont3 = $.CreatePanel("Panel", $.GetContextPanel(), "AttackSpeedContainer");
	statsCont3.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont3.FindChildTraverse("StatUpgradeLabel").text = "ATTACK SPEED (+10)";
	statsCont3.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont3.SetParent(upgradeContent)
	
	var statsCont6 = $.CreatePanel("Panel", $.GetContextPanel(), "AttackRangeContainer");
	statsCont6.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont6.FindChildTraverse("StatUpgradeLabel").text = "ATTACK RANGE (+50)";
	statsCont6.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont6.SetParent(upgradeContent)
	
	var statsCont4 = $.CreatePanel("Panel", $.GetContextPanel(), "SpellAmpContainer");
	statsCont4.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont4.FindChildTraverse("StatUpgradeLabel").text = "SPELL AMPLIFICATION (+10%)";
	statsCont4.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont4.SetParent(upgradeContent)
	
	var statsCont5 = $.CreatePanel("Panel", $.GetContextPanel(), "AreaDamageContainer");
	statsCont5.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont5.FindChildTraverse("StatUpgradeLabel").text = "AREA DAMAGE (+10%)";
	statsCont5.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont5.SetParent(upgradeContent)
	
	var statsCont6 = $.CreatePanel("Panel", $.GetContextPanel(), "StatusAmpContainer");
	statsCont6.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont6.FindChildTraverse("StatUpgradeLabel").text = "STATUS AMPLIFICATION (+5%)";
	statsCont6.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont6.SetParent(upgradeContent)
	
	var statsCont7 = $.CreatePanel("Panel", $.GetContextPanel(), "HealAmpContainer");
	statsCont7.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont7.FindChildTraverse("StatUpgradeLabel").text = "HEAL AMPLIFICATION (+5%)";
	statsCont7.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont7.SetParent(upgradeContent)
	
	var statsCont8 = $.CreatePanel("Panel", $.GetContextPanel(), "ManaContainer");
	statsCont8.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont8.FindChildTraverse("StatUpgradeLabel").text = "MANA (+150)";
	statsCont8.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont8.SetParent(upgradeContent)
	
	var statsCont9 = $.CreatePanel("Panel", $.GetContextPanel(), "HealthContainer");
	statsCont9.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont9.FindChildTraverse("StatUpgradeLabel").text = "HEALTH (+200)";
	statsCont9.FindChildTraverse("ValueLabelSnipper").text = "300";
	statsCont9.SetParent(upgradeContent)
	
	var statsCont10 = $.CreatePanel("Panel", $.GetContextPanel(), "StatusResistContainer");
	statsCont10.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont10.FindChildTraverse("StatUpgradeLabel").text = "STATUS RESISTANCE (+5%)";
	statsCont10.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont10.SetParent(upgradeContent)
	
	var statsCont11 = $.CreatePanel("Panel", $.GetContextPanel(), "ArmorContainer");
	statsCont11.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont11.FindChildTraverse("StatUpgradeLabel").text = "ARMOR (+3)";
	statsCont11.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont11.SetParent(upgradeContent)
	
	var statsCont12 = $.CreatePanel("Panel", $.GetContextPanel(), "MagicResistContainer");
	statsCont12.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont12.FindChildTraverse("StatUpgradeLabel").text = "MAGIC RESISTANCE (+5%)";
	statsCont12.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont12.SetParent(upgradeContent)
	
	var statsCont13 = $.CreatePanel("Panel", $.GetContextPanel(), "MoveSpeedContainer");
	statsCont13.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont13.FindChildTraverse("StatUpgradeLabel").text = "MOVEMENT SPEED (+15)";
	statsCont13.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont13.SetParent(upgradeContent)
	
	var statsCont14 = $.CreatePanel("Panel", $.GetContextPanel(), "CriticalChanceContainer");
	statsCont14.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont14.FindChildTraverse("StatUpgradeLabel").text = "CRITICAL CHANCE (+2.5%)";
	statsCont14.FindChildTraverse("ValueLabelSnipper").text = "750";
	statsCont14.SetParent(upgradeContent)
	
	var statsCont15 = $.CreatePanel("Panel", $.GetContextPanel(), "CriticalDamageContainer");
	statsCont15.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont15.FindChildTraverse("StatUpgradeLabel").text = "CRITICAL DAMAGE (+10%)";
	statsCont15.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont15.SetParent(upgradeContent)
	
	var statsCont16 = $.CreatePanel("Panel", $.GetContextPanel(), "ManaCostReductionContainer");
	statsCont16.BLoadLayoutSnippet("AttributePurchaseButton")
	statsCont16.FindChildTraverse("StatUpgradeLabel").text = "MANA COST REDUCTION (+5%)";
	statsCont16.FindChildTraverse("ValueLabelSnipper").text = "250";
	statsCont16.SetParent(upgradeContent)
})();
