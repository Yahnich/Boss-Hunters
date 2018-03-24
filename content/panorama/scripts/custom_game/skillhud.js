// DEFAULT HUD INITIALIZATION
var lowerHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud")
var talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var levelUp = lowerHud.FindChildTraverse("level_stats_frame")

var localID = Players.GetLocalPlayer()

lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "collapse";


lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "visible";

talentHud.FindChildTraverse("StatBranch").SetPanelEvent("onmouseover", function(){});
talentHud.FindChildTraverse("StatBranch").SetPanelEvent("onmouseout", function(){});
talentHud.FindChildTraverse("StatBranch").SetPanelEvent("onactivate", ToggleStatsPanel);

levelUp.FindChildTraverse("LevelUpButton").SetPanelEvent("onactivate", ToggleStatsPanel);
levelUp.FindChildTraverse("LevelUpTab").SetPanelEvent("onactivate", ToggleStatsPanel);
levelUp.FindChildTraverse("LevelUpIcon").style.visibility = "collapse";
var levelLabel = $.CreatePanel("Label", $.GetContextPanel(), "LevelUpLabel");
levelLabel.SetParent( levelUp.FindChildTraverse("LevelUpButton") )
levelLabel.SetHasClass("LevelUpLabel", true)
levelLabel.text = "0"

// EVENT SUBSCRIPTION
GameEvents.Subscribe("dota_player_gained_level", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_learned_ability", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_update_query_unit", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_upgraded_stats", UpdateStatsPanel);

// OTHER
MOVESPEED_TABLE = [0,15,20,25,30,35,40,45,50,55,60]
MANA_TABLE = [0,250,500,750,1000,1250,1500,1750,2000,2250,2500]
MANA_REGEN_TABLE = [0,3,6,9,12,15,18,21,24,27,30]
HEAL_AMP_TABLE = [0,10,20,30,40,50]

// OFFENSE
ATTACK_DAMAGE_TABLE = [0,20,40,60,80,100,120,140,160,180,200]
SPELL_AMP_TABLE = [0,10,15,20,25,30,35,40,45,50,55]
COOLDOWN_REDUCTION_TABLE = [0,10,15,20,25]
ATTACK_SPEED_TABLE = [0,20,40,60,80,100,120,140,160,180,200]
STATUS_AMP_TABLE = [0,10,15,20,25]

// DEFENSE
ARMOR_TABLE = [0,2,4,6,8,10,12,14,16,18,20]
MAGIC_RESIST_TABLE = [0,5,10,15,20,25,30,35,40,45,50]
DAMAGE_BLOCK_TABLE = [0,20,30,40,50,60]
ATTACK_RANGE_TABLE = [0,50,100,150,200,250,300,350,400,450,500]
HEALTH_TABLE = [0,150,300,450,600,750,900,1050,1200,1350,1500]
HEALTH_REGEN_TABLE = [0,3,6,9,12,15,18,21,24,27,30]
STATUS_REDUCTION_TABLE = [0,10,15,20,25]

STATS_STATE_OFFENSE = 1
STATS_STATE_DEFENSE = 2
STATS_STATE_OTHER = 3
STATS_STATE_UNIQUE = 4

var lastRememberedState = STATS_STATE_OFFENSE
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

$("#RootContainer").SetHasClass("IsHidden", true)

function ToggleStatsPanel()
{
	var statsPanel = $("#RootContainer");
	statsPanel.SetHasClass("IsHidden", !statsPanel.BHasClass("IsHidden") );
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	UpdateStatsPanel()
}

function RefreshStatsPanel()
{
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if ( !Entities.IsRealHero( lastRememberedHero ) ){ 
		lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
	}

	if(lastRememberedState == STATS_STATE_OFFENSE){
		LoadOffenseLayout()
	} else if(lastRememberedState == STATS_STATE_DEFENSE){
		LoadDefenseLayout()
	} else if(lastRememberedState == STATS_STATE_OTHER){
		LoadOtherLayout()
	} else if(lastRememberedState == STATS_STATE_UNIQUE){
		LoadUniqueLayout()
	}
}

function UpdateStatsPanel()
{
	var selectedHero = Players.GetLocalPlayerPortraitUnit()
	if ( Entities.IsRealHero( selectedHero ) ){
		if ( selectedHero == Players.GetPlayerHeroEntityIndex( localID ) ){
			if( Entities.GetAbilityPoints( selectedHero ) > 0){
				levelUp.style.visibility = "visible";
			} else {
				levelUp.style.visibility = "collapse";
			}
		} else {
			levelUp.style.visibility = "collapse";
		}
	} else {
		levelUp.style.visibility = "collapse";
	}
	// only refresh if talent panel is visible
	if( !($("#RootContainer").BHasClass("IsHidden")) ){
		RefreshStatsPanel()
	}
	levelLabel.text = Entities.GetAbilityPoints( selectedHero )
}

function ClearStatsTypeContainer(){
	var statsTypeContainer = $("#StatsTypeContainer")
	for(var stat of statsTypeContainer.Children()){
		stat.style.visibility = "collapse"
		stat.RemoveAndDeleteChildren()
		stat.DeleteAsync(0)
	}
}

function UpgradeAbility(nettableString)
{
	GameEvents.SendCustomGameEventToServer( "send_player_upgraded_stats", {pID : localID, entindex : lastRememberedHero,  skill : nettableString} )
}

function LoadOffenseLayout()
{
	lastRememberedState = STATS_STATE_OFFENSE
	var statsTypeContainer = $("#StatsTypeContainer")
	ClearStatsTypeContainer()
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", true)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", false)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", false)
	var statsNetTable = CustomNetTables.GetTableValue("stats_panel", lastRememberedHero)
	var attackDamage = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerAttackDamage");
	attackDamage.BLoadLayoutSnippet("StatsContainer")
	var adLvl = statsNetTable.ad 
	attackDamage.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_ATTACK_DAMAGE", attackDamage) + " (+ " + ATTACK_DAMAGE_TABLE[adLvl] + " )"
	attackDamage.FindChildTraverse("StatsTypeLevel").text = adLvl + "/" + (ATTACK_DAMAGE_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || adLvl >= ATTACK_DAMAGE_TABLE.length - 1){
		attackDamage.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		attackDamage.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("ad")});
	}
	if( ATTACK_DAMAGE_TABLE[adLvl + 1] == null ){ // max level
		attackDamage.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", attackDamage, "Stat maxed!")});
		attackDamage.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", attackDamage);});
	} else { // can be leveled
		attackDamage.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", attackDamage, "Next Level: +" + ATTACK_DAMAGE_TABLE[adLvl + 1]);});
		attackDamage.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", attackDamage);});
	}
	
	var attackSpeed = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerAttackSpeed");
	attackSpeed.BLoadLayoutSnippet("StatsContainer")
	var asLvl = statsNetTable.as
	attackSpeed.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_ATTACK_SPEED", attackSpeed) + " (+ " + ATTACK_SPEED_TABLE[asLvl] + " )"
	attackSpeed.FindChildTraverse("StatsTypeLevel").text = asLvl + "/" + (ATTACK_SPEED_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || asLvl >= ATTACK_SPEED_TABLE.length - 1){
		attackSpeed.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		attackSpeed.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("as")});
	}
	if( ATTACK_SPEED_TABLE[asLvl + 1] == null ){ // max level
		attackSpeed.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", attackSpeed, "Stat maxed!")});
		attackSpeed.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", attackSpeed);});
	} else { // can be leveled
		attackSpeed.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", attackSpeed, "Next Level: +" + ATTACK_SPEED_TABLE[asLvl + 1]);});
		attackSpeed.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", attackSpeed);});
	}
	
	var spellAmp = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerSpellAmp");
	spellAmp.BLoadLayoutSnippet("StatsContainer")
	var saLvl = statsNetTable.sa
	spellAmp.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_SPELL_AMP", spellAmp) + " (+ " + SPELL_AMP_TABLE[saLvl] + "% )"
	spellAmp.FindChildTraverse("StatsTypeLevel").text = saLvl + "/" + (SPELL_AMP_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || saLvl >= SPELL_AMP_TABLE.length - 1){
		spellAmp.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		spellAmp.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("sa")});
	}
	if( SPELL_AMP_TABLE[saLvl + 1] == null ){ // max level
		spellAmp.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", spellAmp, "Stat maxed!")});
		spellAmp.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", spellAmp);});
	} else { // can be leveled
		spellAmp.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", spellAmp, "Next Level: +" + SPELL_AMP_TABLE[saLvl + 1] + "%");});
		spellAmp.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", spellAmp);});
	}
	
	var cooldownReduction = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerCooldownReduction");
	cooldownReduction.BLoadLayoutSnippet("StatsContainer")
	var cdrLvl = statsNetTable.cdr
	cooldownReduction.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_COOLDOWN_REDUCTION", cooldownReduction) + " (+ " + COOLDOWN_REDUCTION_TABLE[cdrLvl] + "% )"
	cooldownReduction.FindChildTraverse("StatsTypeLevel").text = cdrLvl + "/" + (COOLDOWN_REDUCTION_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || cdrLvl >= COOLDOWN_REDUCTION_TABLE.length - 1){
		cooldownReduction.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		cooldownReduction.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("cdr")});
	}
	if( COOLDOWN_REDUCTION_TABLE[cdrLvl + 1] == null ){ // max level
		cooldownReduction.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", cooldownReduction, "Stat maxed!")});
		cooldownReduction.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", cooldownReduction);});
	} else { // can be leveled
		cooldownReduction.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", cooldownReduction, "Next Level: +" + COOLDOWN_REDUCTION_TABLE[cdrLvl + 1] + "%");});
		cooldownReduction.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", cooldownReduction);});
	}
	
	var statusAmp = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerStatusAmp");
	statusAmp.BLoadLayoutSnippet("StatsContainer")
	var staLvl = statsNetTable.sta
	statusAmp.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_STATUS_AMP", statusAmp) + " (+ " + STATUS_AMP_TABLE[staLvl] + "% )"
	statusAmp.FindChildTraverse("StatsTypeLevel").text = staLvl + "/" + (STATUS_AMP_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || staLvl >= STATUS_AMP_TABLE.length - 1){
		statusAmp.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		statusAmp.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("sta")});
	}
	if( STATUS_AMP_TABLE[staLvl + 1] == null ){ // max level
		statusAmp.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", statusAmp, "Stat maxed!")});
		statusAmp.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", statusAmp);});
	} else { // can be leveled
		statusAmp.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", statusAmp, "Next Level: +" + STATUS_AMP_TABLE[staLvl + 1] + "%");});
		statusAmp.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", statusAmp);});
	}
}

function LoadDefenseLayout()
{
	lastRememberedState = STATS_STATE_DEFENSE
	var statsTypeContainer = $("#StatsTypeContainer")
	
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", true)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", false)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", false)
	ClearStatsTypeContainer()
	
	var statsNetTable = CustomNetTables.GetTableValue("stats_panel", lastRememberedHero)
	var armor = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerArmor");
	armor.BLoadLayoutSnippet("StatsContainer")
	var armorLvl = statsNetTable.pr
	armor.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_ARMOR", armor) + " (+ " + ARMOR_TABLE[armorLvl] + " )"
	armor.FindChildTraverse("StatsTypeLevel").text = armorLvl + "/" + (ARMOR_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || armorLvl >= ARMOR_TABLE.length - 1){
		armor.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		armor.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("pr")});
	}
	if( ARMOR_TABLE[armorLvl + 1] == null ){ // max level
		armor.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", armor, "Stat maxed!")});
		armor.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", armor);});
	} else { // can be leveled
		armor.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", armor, "Next Level: +" + ARMOR_TABLE[armorLvl + 1]);});
		armor.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", armor);});
	}
	
	var magicResist = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerMagicResist");
	magicResist.BLoadLayoutSnippet("StatsContainer")
	var mrLvl = statsNetTable.mr
	magicResist.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_MAGIC_RESIST", magicResist) + " (+ " + MAGIC_RESIST_TABLE[mrLvl] + "% )"
	magicResist.FindChildTraverse("StatsTypeLevel").text = mrLvl + "/" + (MAGIC_RESIST_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || mrLvl >= MAGIC_RESIST_TABLE.length - 1){
		magicResist.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		magicResist.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("mr")});
	}
	if( MAGIC_RESIST_TABLE[mrLvl + 1] == null ){ // max level
		magicResist.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", magicResist, "Stat maxed!")});
		magicResist.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", magicResist);});
	} else { // can be leveled
		magicResist.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", magicResist, "Next Level: +" + MAGIC_RESIST_TABLE[mrLvl + 1] + "%");});
		magicResist.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", magicResist);});
	}
	
	if ( Entities.IsRangedAttacker( lastRememberedHero ) ){
		var attackRange = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerAttackRange");
		var arLvl = statsNetTable.ar
		attackRange.BLoadLayoutSnippet("StatsContainer")
		attackRange.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_ATTACK_RANGE", attackRange) + " (+ " + ATTACK_RANGE_TABLE[arLvl] + " )"
		attackRange.FindChildTraverse("StatsTypeLevel").text = arLvl + "/" + (ATTACK_RANGE_TABLE.length - 1)
		if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || arLvl >= ATTACK_RANGE_TABLE.length - 1){
			attackRange.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
		} else {
			attackRange.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("ar")});
		}
		if( ATTACK_RANGE_TABLE[arLvl + 1] == null ){ // max level
			attackRange.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", attackRange, "Stat maxed!")});
			attackRange.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", attackRange);});
		} else { // can be leveled
			attackRange.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", attackRange, "Next Level: +" + ATTACK_RANGE_TABLE[arLvl + 1]);});
			attackRange.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", attackRange);});
		}
	} else {
		var damageBlock = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerDamageBlock");
		damageBlock.BLoadLayoutSnippet("StatsContainer")
		var dbLvl = statsNetTable.db
		damageBlock.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_DAMAGE_BLOCK", damageBlock) + " (+ " + DAMAGE_BLOCK_TABLE[dbLvl] + " )"
		damageBlock.FindChildTraverse("StatsTypeLevel").text = dbLvl + "/" + (DAMAGE_BLOCK_TABLE.length - 1)
		if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || dbLvl >= DAMAGE_BLOCK_TABLE.length - 1){
			damageBlock.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
		} else {
			damageBlock.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("db")});
		}
		if( DAMAGE_BLOCK_TABLE[dbLvl + 1] == null ){ // max level
			damageBlock.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", damageBlock, "Stat maxed!")});
			damageBlock.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", damageBlock);});
		} else { // can be leveled
			damageBlock.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", damageBlock, "Next Level: +" + DAMAGE_BLOCK_TABLE[dbLvl + 1]);});
			damageBlock.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", damageBlock);});
		}
	}
	
	var health = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerHealth");
	health.BLoadLayoutSnippet("StatsContainer")
	var hpLvl = statsNetTable.hp
	health.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_HEALTH", health) + " (+ " + HEALTH_TABLE[hpLvl] + " )"
	health.FindChildTraverse("StatsTypeLevel").text = hpLvl + "/" + (HEALTH_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || hpLvl >= HEALTH_TABLE.length - 1){
		health.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		health.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("hp")});
	}
	if( HEALTH_TABLE[hpLvl + 1] == null ){ // max level
		health.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", health, "Stat maxed!")});
		health.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", health);});
	} else { // can be leveled
		health.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", health, "Next Level: +" + HEALTH_TABLE[hpLvl + 1]);});
		health.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", health);});
	}
	
	var healthRegen = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerHealthRegen");
	healthRegen.BLoadLayoutSnippet("StatsContainer")
	var hprLvl = statsNetTable.hpr
	healthRegen.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_HEALTH_REGEN", healthRegen) + " (+ " + HEALTH_REGEN_TABLE[hprLvl] + " )"
	healthRegen.FindChildTraverse("StatsTypeLevel").text = hprLvl + "/" + (HEALTH_REGEN_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || hprLvl >= HEALTH_REGEN_TABLE.length - 1){
		healthRegen.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		healthRegen.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("hpr")});
	}
	if( HEALTH_REGEN_TABLE[hprLvl + 1] == null ){ // max level
		healthRegen.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", healthRegen, "Stat maxed!")});
		healthRegen.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", healthRegen);});
	} else { // can be leveled
		healthRegen.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", healthRegen, "Next Level: +" + HEALTH_REGEN_TABLE[hprLvl + 1]);});
		healthRegen.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", healthRegen);});
	}
	
	var statusResist = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerStatusResistance");
	statusResist.BLoadLayoutSnippet("StatsContainer")
	var srLvl = statsNetTable.sr
	statusResist.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_STATUS_REDUCTION", statusResist) + " (+ " + STATUS_REDUCTION_TABLE[srLvl] + "% )"
	statusResist.FindChildTraverse("StatsTypeLevel").text = srLvl + "/" + (STATUS_REDUCTION_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || srLvl >= STATUS_REDUCTION_TABLE.length - 1){
		statusResist.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		statusResist.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("sr")});
	}
	if( STATUS_REDUCTION_TABLE[srLvl + 1] == null ){ // max level
		statusResist.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", statusResist, "Stat maxed!")});
		statusResist.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", statusResist);});
	} else { // can be leveled
		statusResist.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", statusResist, "Next Level: +" + STATUS_REDUCTION_TABLE[srLvl + 1] + "%");});
		statusResist.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", statusResist);});
	}
}

function LoadOtherLayout()
{
	lastRememberedState = STATS_STATE_OTHER
	var statsTypeContainer = $("#StatsTypeContainer")
	var statsNetTable = CustomNetTables.GetTableValue("stats_panel", lastRememberedHero)
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", true)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", false)
	ClearStatsTypeContainer()
	
	var moveSpeed = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerMoveSpeed");
	moveSpeed.BLoadLayoutSnippet("StatsContainer")
	var msLevel = statsNetTable.ms
	moveSpeed.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_MOVE_SPEED", moveSpeed) + " (+ " + MOVESPEED_TABLE[msLevel] + " )"
	moveSpeed.FindChildTraverse("StatsTypeLevel").text = msLevel + "/" + (MOVESPEED_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || msLevel >= MOVESPEED_TABLE.length - 1){
		moveSpeed.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		moveSpeed.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("ms")});
	}
	if( MOVESPEED_TABLE[msLevel + 1] == null ){ // max level
		moveSpeed.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", moveSpeed, "Stat maxed!")});
		moveSpeed.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", moveSpeed);});
	} else { // can be leveled
		moveSpeed.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", moveSpeed, "Next Level: +" + MOVESPEED_TABLE[msLevel + 1]);});
		moveSpeed.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", moveSpeed);});
	}
	
	var mana = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerMana");
	mana.BLoadLayoutSnippet("StatsContainer")
	var mpLevel = statsNetTable.mp
	mana.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_MANA", mana) + " (+ " + MANA_TABLE[mpLevel] + " )"
	mana.FindChildTraverse("StatsTypeLevel").text = mpLevel + "/" + (MANA_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || mpLevel >= MANA_TABLE.length - 1){
		mana.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		mana.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("mp")});
	}
	if( MANA_TABLE[mpLevel + 1] == null ){ // max level
		mana.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", mana, "Stat maxed!")});
		mana.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", mana);});
	} else { // can be leveled
		mana.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", mana, "Next Level: +" + MANA_TABLE[mpLevel + 1]);});
		mana.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", mana);});
	}
	
	var manaRegen = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerManaRegen");
	manaRegen.BLoadLayoutSnippet("StatsContainer")
	var mprLevel = statsNetTable.mpr
	manaRegen.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_MANA_REGEN", manaRegen) + " (+ " + MANA_REGEN_TABLE[mprLevel] + " )"
	manaRegen.FindChildTraverse("StatsTypeLevel").text = mprLevel + "/" + (MANA_REGEN_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || mprLevel >= MANA_REGEN_TABLE.length - 1){
		manaRegen.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		manaRegen.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("mpr")});
	}
	if( MANA_REGEN_TABLE[mprLevel + 1] == null ){ // max level
		manaRegen.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", manaRegen, "Stat maxed!")});
		manaRegen.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", manaRegen);});
	} else { // can be leveled
		manaRegen.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", manaRegen, "Next Level: +" + MANA_REGEN_TABLE[mprLevel + 1]);});
		manaRegen.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", manaRegen);});
	}
	
	var healAmp = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerHealAmp");
	healAmp.BLoadLayoutSnippet("StatsContainer")
	var haLevel = statsNetTable.ha
	healAmp.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_HEAL_AMP", healAmp) + " (+ " + HEAL_AMP_TABLE[haLevel] + "% )"
	healAmp.FindChildTraverse("StatsTypeLevel").text = haLevel + "/" + (HEAL_AMP_TABLE.length - 1)
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || haLevel >= HEAL_AMP_TABLE.length - 1){
		healAmp.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		healAmp.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("ha")});
	}
	if( HEAL_AMP_TABLE[haLevel + 1] == null ){ // max level
		healAmp.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", healAmp, "Stat maxed!")});
		healAmp.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", healAmp);});
	} else { // can be leveled
		healAmp.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", healAmp, "Next Level: +" + HEAL_AMP_TABLE[haLevel + 1]);});
		healAmp.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", healAmp);});
	}
	
	var allStats = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerHealAmp");
	allStats.BLoadLayoutSnippet("StatsContainer")
	var bonusAll = statsNetTable["all"]
	allStats.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_ALL_STATS", allStats)
	allStats.FindChildTraverse("StatsTypeLevel").text = "+ " + bonusAll * 2

	allStats.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", allStats, "+2 All Stats");});
	allStats.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", allStats);});
	
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) ){
		allStats.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		allStats.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("all")});
	}
}

function LoadUniqueLayout()
{
	lastRememberedState = STATS_STATE_UNIQUE
	var statsTypeContainer = $("#StatsTypeContainer")
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", false)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", true)
	ClearStatsTypeContainer()
	
	var levelLabel = $.CreatePanel("Label", statsTypeContainer, "RequiredLevelLabel");
	levelLabel.SetHasClass("RequiredLevelLabel", true)
	levelLabel.text = "Next level requirement: 10"
	
	var talents = []
	var talentsSkilled = CustomNetTables.GetTableValue("talents", lastRememberedHero)
	var talentsSkilledCount = 0
	for(var talent in talentsSkilled){
		talentsSkilledCount++
	}
	var levelRequirement = 10 + talentsSkilledCount * 10
	for (var id = 0; id < Entities.GetAbilityCount( lastRememberedHero ); id++) {
		var abilityID = Entities.GetAbility( lastRememberedHero, id )
		var abilityName = Abilities.GetAbilityName( abilityID )
		var isTalent = (Abilities.GetAbilityType( abilityID ) & ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES && abilityName.match(/special_bonus/g) == "special_bonus"
		if ( isTalent ){
			if(talents[id] == null) // link sister abilities
			{
				CreateTalentContainer(levelRequirement, statsTypeContainer, talentsSkilled, talents, abilityID, id) 
			}
		}
	}
	
	levelLabel.text = "Next level requirement: " + levelRequirement
}

function CreateTalentContainer(levelRequirement, statsTypeContainer, talentsSkilled, talents, abilityID, id){
	talents[id] = id + 1
	talents[id + 1] = id 
	talent1ID = abilityID
	talent2ID = Entities.GetAbility( lastRememberedHero, id + 1 )
	
	var talent1Name = Abilities.GetAbilityName( talent1ID )
	var talent2Name = Abilities.GetAbilityName( talent2ID )
	
	
	var talent = $.CreatePanel("Panel", statsTypeContainer, "Talentchoice" + id);
	talent.BLoadLayoutSnippet("TalentContainer")

	talent.FindChildTraverse("TalentLeftLabel").text = $.Localize( "#DOTA_Tooltip_Ability_" + talent1Name, talent)
	talent.FindChildTraverse("TalentRightLabel").text = $.Localize( "#DOTA_Tooltip_Ability_" + talent2Name, talent)
	
	var talentLeft = talent.FindChildTraverse("TalentSubLeft")
	var talentRight = talent.FindChildTraverse("TalentSubRight")
	
	talentLeft.nameid = talent1Name
	talentLeft.talentname = $.Localize( "#DOTA_Tooltip_Ability_" + talent1Name, talentLeft )
	talentLeft.talentdescr = $.Localize( "#DOTA_Tooltip_Ability_" + talent1Name + "_Description", talentLeft)
	
	talentRight.nameid = talent2Name
	talentRight.talentname = $.Localize( "#DOTA_Tooltip_Ability_" + talent2Name, talentRight )
	talentRight.talentdescr = $.Localize( "#DOTA_Tooltip_Ability_" + talent2Name + "_Description", talentRight)
	
	if( talentRight.talentdescr != ("DOTA_Tooltip_Ability_" + talent2Name + "_Description") ){
		talentRight.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTitleTextTooltip", talentRight, talentRight.talentname, talentRight.talentdescr);});
		talentRight.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTitleTextTooltip", talentRight);});
	}
	if ( talentLeft.talentdescr != ("DOTA_Tooltip_Ability_" + talent1Name + "_Description") ){
		talentLeft.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTitleTextTooltip", talentLeft, talentLeft.talentname, talentLeft.talentdescr);});
		talentLeft.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTitleTextTooltip", talentLeft);});
	}
	var talent1IsSkilled = (talentsSkilled != null && talentsSkilled[talent1Name] != null)
	var talent2IsSkilled = (talentsSkilled != null && talentsSkilled[talent2Name] != null)
	var talentIsSkilled = talent1IsSkilled || talent2IsSkilled
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || Entities.GetLevel( lastRememberedHero ) < levelRequirement){
		talentLeft.SetHasClass("TalentCannotBeSkilled", !talent1IsSkilled)
		talentRight.SetHasClass("TalentCannotBeSkilled", !talent2IsSkilled)
	} else if(talentIsSkilled){
		talentLeft.SetHasClass("TalentCannotBeSkilled", talent2IsSkilled)
		talentRight.SetHasClass("TalentCannotBeSkilled", talent1IsSkilled)
	} else {
		talentLeft.SetHasClass("TalentCanBeSkilled", !talent1IsSkilled)
		talentRight.SetHasClass("TalentCanBeSkilled", !talent2IsSkilled)
	}
	if(talentIsSkilled){
		talentLeft.SetHasClass("TalentIsSkilled", talent1IsSkilled)
		talentRight.SetHasClass("TalentIsSkilled", talent2IsSkilled)
	}
	if(talentLeft.BHasClass("TalentCanBeSkilled")){
		talentLeft.SetPanelEvent("onactivate", function(){SelectTalent(talentLeft.nameid)});
	}
	if(talentRight.BHasClass("TalentCanBeSkilled")){
		talentRight.SetPanelEvent("onactivate", function(){SelectTalent(talentRight.nameid)});
	}
}

function SelectTalent(talent)
{
	GameEvents.SendCustomGameEventToServer( "send_player_selected_talent", {pID : localID, entindex : lastRememberedHero,  talent : talent} )
}