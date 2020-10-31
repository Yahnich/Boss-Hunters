// DEFAULT HUD INITIALIZATION
var mainHud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();
var heroSelection = mainHud.FindChildTraverse("Hud").FindChildTraverse("PreGame");

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID );

var direTeam = heroSelection.FindChildTraverse("DireTeamPlayers");
var radiantTeam = heroSelection.FindChildTraverse("RadiantTeamPlayers");

(function(){
	direTeam.style.visibility = "collapse";
})();