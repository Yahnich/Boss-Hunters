// DEFAULT HUD INITIALIZATION
let lowerHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud")
let talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
let levelUp = lowerHud.FindChildTraverse("level_stats_frame")

let localID = Players.GetLocalPlayer()
let lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
 
lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "collapse";

lowerHud.FindChildTraverse("StatBranchDrawer").visible = false
let statPipContainer = talentHud.FindChildTraverse("StatPipContainer")
statPipContainer.SetPanelEvent("onmouseover", function(){});
statPipContainer.SetPanelEvent("onmouseout", function(){});
statPipContainer.SetPanelEvent("onactivate", Reveal);

levelUp.FindChildTraverse("LevelUpButton").SetPanelEvent("onactivate", Reveal);
levelUp.FindChildTraverse("LevelUpTab").SetPanelEvent("onactivate", Reveal);
levelUp.FindChildTraverse("LevelUpIcon").style.visibility = "collapse";
let levelLabel
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
var serverRequestInProgress = false;

if (lastRememberedHero != -1){
	RequestNewPanelData( )
}
function ServerResponded(){
	hasQueuedAction = false;
	serverRequestInProgress = false; 
}
function UpdateSkillPoints(eventInfo)
{
	let eventUnit = Players.GetPlayerHeroEntityIndex( localID )
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

const romanOne = "I"
const romanFive = "V"
const romanTen = "X"

function valueToRoman( value ){
	var romanNumeral = ""
	
	while(value >= 10){
		value = value - 10
		romanNumeral = romanNumeral + romanTen
	}
	if(value == 9){
		romanNumeral = romanNumeral + romanOne + romanTen
	};
	if( value == 5){
		romanNumeral = romanNumeral + romanFive
	}
	if( value == 4){

		romanNumeral = romanNumeral + romanOne + romanFive
	} else {
		while(value > 0){
			value = value - 1
			romanNumeral = romanNumeral + romanOne
		}
	}
	
	return romanNumeral
}

RemovePanel('RootContainer')
function CreateMasteryPanel( panelData ){
	let buttonPanel = $("#RootContainer")
	if(buttonPanel.requestOpen){
		buttonPanel.requestOpen = false
		buttonPanel.SetHasClass("IsHidden", false)
	}
	let masteryContainer = $("#TalentRowContainer")
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
	let netTable = panelData.response
	$.Msg("message received sir")
	for(let stat of masteryContainer.Children()){
		stat.style.visibility = "collapse"
		stat.RemoveAndDeleteChildren()
		stat.DeleteAsync(0)
	}
	var masteryContainerCounter = 0
	let rowsCreated = 1
	let talentRowContainer = $.CreatePanel("Panel", masteryContainer, "RowContainer" + rowsCreated);
	talentRowContainer.SetHasClass("GenericTalentsRow", true)
	let purchaseAble = Entities.GetAbilityPoints( lastRememberedHero ) >= 1 && lastRememberedHero == Players.GetPlayerHeroEntityIndex( localID )
	if(netTable != null && netTable.heroMasteries != null){
		let heroMasteries = netTable.heroMasteries
		for( let talentType in netTable.heroMasteries ){
			let talentData = netTable.heroMasteries[talentType]
			if ( talentType != 'INF_STATS' ){
				masteryContainerCounter++;
				if(masteryContainerCounter > 4){
					masteryContainerCounter = 0;
					rowsCreated++
					talentRowContainer = $.CreatePanel("Panel", masteryContainer, "RowContainer" + rowsCreated);
					talentRowContainer.SetHasClass("GenericTalentsRow", true)
				}
				
				let talentContainer = $.CreatePanel("Panel", talentRowContainer, "TalentContainer_"+talentType);
				talentContainer.BLoadLayoutSnippet("TalentContainer")
				
				let stars = talentData.maxTier;
				let starContainer = talentContainer.FindChildTraverse("GenericTalentStars")
				for (i = 1; i <= stars; i++){
					let star = $.CreatePanel("Image", starContainer, "LevelStar"+i);
					star.AddClass( "LevelStar" );
					if(i <= talentData.talentKeys){ // current star is lower than max level
						star.SetImage("file://{images}/custom_game/icons/leveledTalentTierIcon.png");
					} else if( i == talentData.talentKeys+1 && purchaseAble){
						star.SetImage("file://{images}/custom_game/icons/possibleTalentTierIcon.png");
					} else {
						star.SetImage("file://{images}/custom_game/icons/unleveledTalentTierIcon.png");
					}
					
				}
				
				let titleVar = "#MASTERY_" + talentType
				let titleText = $.Localize( titleVar ) + " " + valueToRoman( talentData.talentTier );
				
				let countIndex = talentData.talentKeys + ""
				let nextIndex = talentData.talentKeys + 1 + ""
				let bonusValue = 0
				let nextValue = 0
				let nextText = "Finished!" 
				if (talentData.talentKeys < stars){
					nextValue = talentData.talentProgression[nextIndex]
					nextText = nextValue + "" 
				}
				if (talentData.talentKeys != 0){
					bonusValue = talentData.talentProgression[countIndex] * 1
				}
				talentContainer.SetDialogVariableInt( "number", bonusValue ); 
				let infoText = $.Localize( titleVar + "_Description", talentContainer) + "<br><br><b>Next tier:</b> " + nextText
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
						AttemptPurchaseTalent( talentType )} );
				
				talentContainer.FindChildTraverse("GenericTalentImage").SetImage("file://{images}/custom_game/icons/MASTERY_" + talentType + "_" + talentData.talentTier + ".png")
			}
		}
		let statsData = netTable.heroMasteries["INF_STATS"]
		let statsPerPoint = statsData.talentProgression[1]
		let totalAllStats = statsPerPoint * statsData.talentKeys
		let costLabel = $.CreatePanel("Label", masteryContainer, "SkillPointCostLabel");
		costLabel.SetHasClass("SkillPointCostLabel", true)
		costLabel.text = "All Stats (+" + statsPerPoint + "): " + totalAllStats;

		costLabel.SetPanelEvent("onmouseover", function(){
			costLabel.SetHasClass("Highlighted", true)
		});
		costLabel.SetPanelEvent("onmouseout", function(){
			costLabel.SetHasClass("Highlighted", false)
		});
		costLabel.SetPanelEvent("onactivate", function(){
			AttemptPurchaseTalent( "INF_STATS" )
		});
	}
	
	hasQueuedAction = false
	UpdateSkillPoints()
	serverRequestInProgress = false
}
 
function AttemptPurchaseTalent(talentType){
	if(hasQueuedAction == false && Players.GetPlayerHeroEntityIndex( localID ) == lastRememberedHero)
	{
		hasQueuedAction = true
		Game.EmitSound( "Button.Click" )
		GameEvents.SendCustomGameEventToServer( "send_player_selected_talent", {pID : localID, entindex : lastRememberedHero,  talent : talentType} )
	}
}

function RemovePanel(panelID)
{
	let buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("IsHidden", true)
	buttonPanel.requestOpen = false
	lowerHud.SetFocus()
}

function BlurPanel(panelID)
{
	// let buttonPanel = $("#"+panelID)
	// buttonPanel.SetHasClass("IsBlurred", true)
}

function FocusPanel(panelID)
{
	let buttonPanel = $("#"+panelID)
	buttonPanel.SetHasClass("IsBlurred", false)
	buttonPanel.SetFocus()
}

function Reveal()
{
	let buttonPanel = $("#RootContainer")
	$.Msg( "??" )
	if(buttonPanel.BHasClass("IsHidden") ){
		buttonPanel.SetFocus()
		buttonPanel.SetHasClass("IsBlurred", false)
		let lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
		buttonPanel.requestOpen = true
		GameEvents.SendCustomGameEventToServer( "dota_player_talent_info_request", {pID : localID, entindex : lastRememberedHero} )
	} else {
		buttonPanel.SetHasClass("IsHidden", true)
	}
}

