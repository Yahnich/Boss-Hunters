var pID = Players.GetLocalPlayer();
var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent();



(function(){
	$.Msg("fuck");
	var hud = dotaHud.FindChildTraverse("HUDElements");
	var minimapBlock = hud.FindChildTraverse("minimap_block");
	var minimapContainer = hud.FindChildTraverse("minimap_container");
	var minimap = hud.FindChildTraverse("minimap");
	minimapContainer.style.verticalAlign = "top";
	minimapBlock.style.horizontalAlign = "right";
	
	var netGraph = hud.FindChildTraverse("NetGraph");
	netGraph.style.marginTop = "244px"
	
	var centerBlockStats = hud.FindChildTraverse("center_with_stats");
	centerBlockStats.style.horizontalAlign = "left";
	
	var centerBlock = hud.FindChildTraverse("center_block");
	centerBlock.style.height = "300px";
	
	var lFlare = hud.FindChildTraverse("left_flare");
	lFlare.style.visibility = "collapse"
	lFlare.style.width = "0px"
	var rFlare = hud.FindChildTraverse("right_flare");
	rFlare.style.visibility = "collapse"
	
	var portraitContainer = hud.FindChildTraverse("PortraitContainer")
	portraitContainer.style.marginLeft = "0px"
	portraitContainer.style.height = "200px";
	portraitContainer.style.width = "200px";
	
	var portraitHud = hud.FindChildTraverse("portraitHUD")
	portraitHud.style.height = "200px";
	portraitHud.style.width = "200px";
	
	var portraitHudOverlay = hud.FindChildTraverse("portraitHUDOverlay")
	portraitHudOverlay.style.height = "200px";
	portraitHudOverlay.style.width = "200px";
	
	var portraitBacker = hud.FindChildTraverse("PortraitBacker")
	portraitBacker.style.marginLeft = "0px"
	portraitBacker.style.height = "200px";
	portraitBacker.style.width = "200px";
	
	var portraitBackerColor = hud.FindChildTraverse("PortraitBackerColor")
	portraitBackerColor.style.marginLeft = "0px"
	portraitBackerColor.style.height = "200px";
	portraitBackerColor.style.width = "200px";
	
	var statContainer = hud.FindChildTraverse("stats_container")
	statContainer.style.marginLeft = "0px"
	statContainer.style.height = "200px";
	statContainer.style.width = "200px";
	
	var statContainer = hud.FindChildTraverse("stats_container")
	statContainer.style.marginLeft = "0px"
	statContainer.style.height = "200px";
	statContainer.style.width = "200px";
	
	var unitName = hud.FindChildTraverse("unitname")
	unitName.style.marginLeft = "0px"
	unitName.style.marginBottom = "0px"
	unitName.style.height = "18px";
	unitName.style.width = "200px";
	
	var unitNameLabel = hud.FindChildTraverse("UnitNameLabel")
	unitNameLabel.style.textAlign = "left"
	unitNameLabel.style.marginLeft = "12px"
	
	var xpContainer = hud.FindChildTraverse("xp")
	xpContainer.style.marginBottom = "153px"
	xpContainer.style.width = "45px";
	
	var xpBar = hud.FindChildTraverse("XPProgress")
	xpBar.style.width = "200px";
	xpBar.style.opacity = "0";
	
	var levelBG = hud.FindChildTraverse("LevelBackground")
	levelBG.style.marginBottom = "-42px"
	levelBG.style.zIndex = "-1"
	
	var abContainer = hud.FindChildTraverse("AbilitiesAndStatBranch")
	abContainer.style.marginLeft = "600px"
	
	var centerBG = hud.FindChildTraverse("center_bg")
	centerBG.style.marginLeft = "600px"
	
	var healthManaContainer = hud.FindChildTraverse("HealthManaContainer")
	healthManaContainer.style.marginLeft = "600px"
	
	var levelUpNotifier = hud.FindChildTraverse("level_stats_frame")
	levelUpNotifier.style.marginLeft = "598px"
	
	var abInset = hud.FindChildrenWithClassTraverse("AbilityInsetShadowLeft")
	abInset[0].style.marginLeft = "600px"
	
})();