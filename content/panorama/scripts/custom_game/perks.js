// DEFAULT HUD INITIALIZATION
var lowerHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud")
var talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var levelUp = lowerHud.FindChildTraverse("level_stats_frame")

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
 
lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "collapse";

lowerHud.FindChildTraverse("StatBranchDrawer").visible = false
var statPipContainer = talentHud.FindChildTraverse("StatPipContainer")
statPipContainer.SetPanelEvent("onmouseover", function(){});
statPipContainer.SetPanelEvent("onmouseout", function(){});
statPipContainer.SetPanelEvent("onactivate", Reveal);

levelUp.FindChildTraverse("LevelUpButton").SetPanelEvent("onactivate", Reveal);
levelUp.FindChildTraverse("LevelUpTab").SetPanelEvent("onactivate", Reveal);
levelUp.FindChildTraverse("LevelUpIcon").style.visibility = "collapse";
var levelLabel
if ( levelUp.FindChildTraverse("LevelUpButton").FindChild("LevelUpLabel") == null || levelUp.FindChildTraverse("LevelUpButton").FindChild("LevelUpLabel") == undefined  ){
	levelLabel = $.CreatePanel("Label", $.GetContextPanel(), "LevelUpLabel");
	levelLabel.SetParent( levelUp.FindChildTraverse("LevelUpButton") )
	levelLabel.SetHasClass("LevelUpLabel", true)
	levelLabel.text = "0"
	UpdateSkillPoints()
} else {
	levelLabel = levelUp.FindChildTraverse("LevelUpButton").FindChild("LevelUpLabel")
	UpdateSkillPoints()
}

// EVENT SUBSCRIPTION
GameEvents.Subscribe("dota_player_gained_level", UpdateSkillPoints);
GameEvents.Subscribe("dota_player_learned_ability", UpdateSkillPoints);
GameEvents.Subscribe("dota_player_update_query_unit", CheckUnitChanged);
GameEvents.Subscribe("dota_player_update_selected_unit", CheckUnitChanged);
GameEvents.Subscribe("dota_player_talent_info_response", CreateMasteryPanel);
GameEvents.Subscribe("dota_player_talent_update", UpdateSkillPoints);
GameEvents.Subscribe("dota_player_talent_update_failure", ServerResponded);

var hasQueuedAction = false;
let conversionArray = {	ATTACK_SPEED:"talentASIcon",
						EVASION:"talentEvIcon",
						HEALTH:"talentHPIcon",
						MOVESPEED:"talentMSIcon",
						MANA:"talentMPIcon",
						MANA_REGEN:"talentMPRIcon",
						SPELL_AMP:"talentSpAIcon",
						AREA_DAMAGE:"talentArDIcon",
						ARMOR:"talentPDIcon",
						MAGIC_RESIST:"talentMDIcon",
						THREAT_AMP:"talentTUIcon",
						STATUS_AMP:"talentStAIcon",
						THREAT_DOWN:"talentTDIcon",
						HEAL_AMP:"talentHAIcon",
						ATTACK_DAMAGE:"talentADIcon",
						}

if (lastRememberedHero != -1){
	RequestNewPanelData( )
}
function ServerResponded(){
	hasQueuedAction = false;
	serverRequestInProgress = false; 
}
function UpdateSkillPoints(eventInfo)
{
	var eventUnit = Players.GetPlayerHeroEntityIndex( localID )
	if( eventInfo != null ){
		if( eventInfo.hero_entindex != null ){
			eventUnit = eventInfo.hero_entindex;
		}
	}
	if(eventUnit != lastRememberedHero){ return; } // if updated unit is not relevant leave bitch
	levelLabel.text = Entities.GetAbilityPoints( lastRememberedHero )
	RequestNewPanelData( )
	hasQueuedAction = false
}

function CheckUnitChanged( eventData ){
	if(lastRememberedHero != Players.GetLocalPlayerPortraitUnit()){
		RequestNewPanelData()
	}
}

var serverRequestInProgress = false
function RequestNewPanelData( ){
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if( Entities.IsRealHero( lastRememberedHero ) && !serverRequestInProgress){
		serverRequestInProgress = true
		GameEvents.SendCustomGameEventToServer( "dota_player_talent_info_request", {pID : localID, entindex : lastRememberedHero} )	
	}
	if ( Entities.IsRealHero( lastRememberedHero ) ){
		if( Entities.GetAbilityPoints( lastRememberedHero ) > 0 ){
			levelUp.style.visibility = "visible";
		} else {
			levelUp.style.visibility = "collapse";
		}
	} else {
		levelUp.style.visibility = "collapse";
	}
}

RemovePanel('MainStatsPanel')
function CreateMasteryPanel( panelData ){
	var buttonPanel = $("#MainStatsPanel")
	if(buttonPanel.requestOpen){
		buttonPanel.requestOpen = false
		buttonPanel.SetHasClass("IsHidden", false)
	}
	var masteryContainer = $("#TalentRowContainer")
	if(panelData != null && panelData.playerID != null)
	{
		if( Players.GetPlayerHeroEntityIndex( panelData.playerID * 1 ) != Players.GetLocalPlayerPortraitUnit() )
		{
			serverRequestInProgress = false
			return
		}
	}
	if(!Entities.IsRealHero( lastRememberedHero )){
		serverRequestInProgress = false
		return
	}
	var netTable = panelData.response
	for(var stat of masteryContainer.Children()){
		stat.style.visibility = "collapse"
		stat.RemoveAndDeleteChildren()
		stat.DeleteAsync(0)
	}
	if(netTable != null){
		var talentProgression = netTable.talentProgression
		var talentKeys = netTable.talentKeys
		var price = 1
		// for(var perkType in talentKeys){
			// var perkIndex = perkType + ""
			// var perkTable = talentKeys[perkType]
			// for(var perkLevel in perkTable){
				// price = price + perkTable[perkLevel]
			// }
		// }
		purchaseAble = price <= Entities.GetAbilityPoints( lastRememberedHero ) && lastRememberedHero == Players.GetPlayerHeroEntityIndex( localID )
		for(var overheadIndex in talentProgression){
			var strIndex = overheadIndex + ""
			var overhead = talentProgression[strIndex]
			var talentRowContainer = $.CreatePanel("Panel", masteryContainer, strIndex + "RowContainer");
			talentRowContainer.SetHasClass("GenericTalentsRow", true)
			for(var table in overhead){
				if(table != "ALL_STATS"){
					CreateTalentContainer( talentRowContainer, talentProgression, talentKeys, overhead, strIndex, table, purchaseAble )
				}
			}
		}
	}
	var statsPerPoint = talentProgression["Generic"]["ALL_STATS"][1]
	var totalAllStats = statsPerPoint * talentKeys["Generic"]["ALL_STATS"]
	var costLabel = $.CreatePanel("Label", masteryContainer, "SkillPointCostLabel");
	costLabel.SetHasClass("SkillPointCostLabel", true)
	costLabel.text = "All Stats (+" + statsPerPoint + "): " + totalAllStats;
	
	costLabel.SetPanelEvent("onmouseover", function(){
			costLabel.SetHasClass("Highlighted", true)
		});
	costLabel.SetPanelEvent("onmouseout", function(){
			costLabel.SetHasClass("Highlighted", false)
		});
	costLabel.SetPanelEvent("onactivate", function(){
			AttemptPurchaseTalent("Generic", "ALL_STATS")} );
	
	hasQueuedAction = false
	UpdateSkillPoints()
	serverRequestInProgress = false
}

function CreateTalentContainer( talentRowContainer, talentProgression, talentKeys, overhead, strIndex, table, purchaseAble ){
	var talentContainer = $.CreatePanel("Panel", talentRowContainer, overhead[table]+"TalentContainer");
	talentContainer.BLoadLayoutSnippet("TalentContainer")
	talentContainer.FindChildTraverse("GenericTalentImage").SetImage("file://{images}/custom_game/icons/" + conversionArray[table] + ".png")

	var stars = 3
	if(overhead[table]["3"] == null){
		talentContainer.FindChildTraverse("LevelStar3").style.visibility = "collapse"
		talentContainer.FindChildTraverse("LevelStar3").RemoveAndDeleteChildren()
		talentContainer.FindChildTraverse("LevelStar3").DeleteAsync(0)
		stars = 2
		if(overhead[table]["2"] == null){
			talentContainer.FindChildTraverse("LevelStar2").style.visibility = "collapse"
			talentContainer.FindChildTraverse("LevelStar2").RemoveAndDeleteChildren()
			talentContainer.FindChildTraverse("LevelStar2").DeleteAsync(0)
			stars = 1
		}
	}
	var starsCompleted = talentKeys[strIndex][table]
	for( i = 1; i <= starsCompleted; i++){
		talentContainer.FindChildTraverse("LevelStar"+i).SetImage("file://{images}/custom_game/icons/leveledTalentTierIcon.png")
	}
	var titleVar = strIndex + "_" + table
	var titleText = $.Localize( titleVar )
	var countIndex = starsCompleted + ""
	var nextIndex = starsCompleted + 1 + ""
	var bonusValue = 0
	var nextValue = 0
	var nextText = "Finished!" 
	if (starsCompleted < stars){
		nextValue = overhead[table][nextIndex]
		nextText = nextValue + "" 
		if(purchaseAble){
			talentContainer.FindChildTraverse("LevelStar"+(starsCompleted+1)).SetImage("file://{images}/custom_game/icons/possibleTalentTierIcon.png")
		}
	}
	if (starsCompleted != 0){
		bonusValue = overhead[table][countIndex] * 1
	}
	talentContainer.SetDialogVariableInt( "number", bonusValue ); 
	var infoText = $.Localize( titleVar + "_Description", talentContainer) + "<br><br><b>Next tier:</b> " + nextText
	talentContainer.SetPanelEvent("onmouseover", function(){
			$.DispatchEvent("DOTAShowTitleTextTooltip", talentContainer, titleText, infoText)
			talentContainer.SetHasClass("Highlighted", true)
		});
	talentContainer.SetPanelEvent("onmouseout", function(){
			$.DispatchEvent("DOTAHideTitleTextTooltip", talentContainer);
			talentContainer.SetHasClass("Highlighted", false)
		});
	talentContainer.SetPanelEvent("onactivate", function(){
			$.DispatchEvent("DOTAHideTitleTextTooltip", talentContainer)
			AttemptPurchaseTalent(strIndex, table)} );
}
 
function AttemptPurchaseTalent(talentRow, talentType){
	if(hasQueuedAction == false && Players.GetPlayerHeroEntityIndex( localID ) == lastRememberedHero)
	{
		hasQueuedAction = true
		Game.EmitSound( "Button.Click" )
		GameEvents.SendCustomGameEventToServer( "send_player_selected_talent", {pID : localID, entindex : lastRememberedHero,  talent : talentType, talentCategory : talentRow} )
	}
}

function RemovePanel(panelID)
{
	var buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("IsHidden", true)
	buttonPanel.requestOpen = false
	lowerHud.SetFocus()
}

function BlurPanel(panelID)
{
	// var buttonPanel = $("#"+panelID)
	// buttonPanel.SetHasClass("IsBlurred", true)
}

function FocusPanel(panelID)
{
	var buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("IsBlurred", false)
	buttonPanel.SetFocus()
}

function Reveal()
{
	var buttonPanel = $("#MainStatsPanel")
	if(buttonPanel.BHasClass("IsHidden") ){
		buttonPanel.SetFocus()
		buttonPanel.SetHasClass("IsBlurred", false)
		var lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
		buttonPanel.requestOpen = true
		GameEvents.SendCustomGameEventToServer( "dota_player_talent_info_request", {pID : localID, entindex : lastRememberedHero} )
	} else {
		buttonPanel.SetHasClass("IsHidden", true)
	}
}

