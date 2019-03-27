function tell_threat()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Tell_Threat", { pID: ID} );
}

GameEvents.Subscribe("dota_player_update_query_unit", UpdatedSelection);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdatedSelection);
GameEvents.Subscribe("bh_update_attack_target", UpdatedAttack);


BH_MINION_TYPE_WILD = 1
BH_MINION_TYPE_UNDEAD = BH_MINION_TYPE_WILD << 1
BH_MINION_TYPE_DEMONIC = BH_MINION_TYPE_UNDEAD << 1
BH_MINION_TYPE_CELESTIAL = BH_MINION_TYPE_DEMONIC << 1

BH_MINION_TYPE_MINION = BH_MINION_TYPE_CELESTIAL << 1
BH_MINION_TYPE_BOSS = BH_MINION_TYPE_MINION << 1

var newestBoss
var prevBoss
var currPID
var localID = Game.GetLocalPlayerID()
$("#targetPanelMain").visible = false;

(function(){
	var wildTypeIcon = $("#WildTypeIcon")
	wildTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", wildTypeIcon, "This enemy is a Wild type enemy")} );
	wildTypeIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", wildTypeIcon)} );
	
	var undeadTypeIcon = $("#UndeadTypeIcon")
	undeadTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", undeadTypeIcon, "This enemy is a Undead type enemy")} );
	undeadTypeIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", undeadTypeIcon)} );
	
	var demonicTypeIcon = $("#DemonicTypeIcon")
	demonicTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", demonicTypeIcon, "This enemy is a Demonic type enemy")} );
	demonicTypeIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", demonicTypeIcon)} );
	
	var celestialTypeIcon = $("#CelestialTypeIcon")
	celestialTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", celestialTypeIcon, "This enemy is a Celestial type enemy")} );
	celestialTypeIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", celestialTypeIcon)} );
	
	var minionTypeIcon = $("#MinionTypeIcon")
	minionTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", minionTypeIcon, "This enemy is a Minion.")} );
	minionTypeIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", minionTypeIcon)} );
	
	var threatButton = $("#threatButton")
	threatButton.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", threatButton, "This is your current threat. Threat dictates who is targeted by the enemy.\n\nRed threat means you have the highest amount of threat in your team, orange means you are second.")} );
	threatButton.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", threatButton)} );
})();

function UpdatedSelection()
{
	var selectedBoss = Players.GetLocalPlayerPortraitUnit();
	if (Entities.GetTeamNumber( selectedBoss ) != Players.GetTeam( localID )){ // target is an enemy
		UpdateCurrentTarget(selectedBoss);
	}
}

function UpdatedAttack(arg)
{
	UpdateCurrentTarget(arg.entindex);
}

function UpdateCurrentTarget(entindex)
{	
	if(newestBoss != entindex){
		newestBoss = entindex;
		if( currPID != null){
			Particles.DestroyParticleEffect( currPID, true );
			Particles.ReleaseParticleIndex( currPID );
		}
		
		var buffContainer = $("#buffBar");
		for( var buff of buffContainer.Children() ){
			buff.style.visibility = "collapse";
			buff.DeleteAsync(0)
		}
		var debuffContainer = $("#debuffBar");
		for( var debuff of debuffContainer.Children() ){
			debuff.style.visibility = "collapse";
			debuff.DeleteAsync(0)
		}
		currPID = Particles.CreateParticle( "particles/ui_mouseactions/unit_highlight.vpcf", ParticleAttachment_t.PATTACH_POINT_FOLLOW, newestBoss );
		Particles.SetParticleControl(currPID, 0, Entities.GetAbsOrigin(newestBoss) );
		Particles.SetParticleControl(currPID, 1, [255,0,0] );
		Particles.SetParticleControl(currPID, 2, [ ( Entities.GetHullRadius( newestBoss ) + Entities.GetPaddedCollisionRadius( newestBoss ) + 12 ) * 3, 1, 1 ] );
	}
}

UpdateHealthBar()
var currBossAbility = "generic_hidden"
function UpdateHealthBar()
{
	var sUnit = newestBoss
	if(GameUI.IsAltDown()){
		$.GetContextPanel().style.marginTop = "9%";
	} else {
		$.GetContextPanel().style.marginTop = "3.5%";
	}
	if(sUnit == null || !Entities.IsAlive( sUnit ) && $("#targetPanelMain").visible){
		$("#targetPanelMain").visible = false;
		var localAbility = $("#currentlyCastAbility")
		localAbility.abilityname = "generic_hidden"
		localAbility.SetHasClass("SpellActiveBorder", false)
		localAbility.SetPanelEvent("onmouseout", function(){} );
		localAbility.SetPanelEvent("onmouseover", function(){} );
		localAbility.SetPanelEvent("onactivate", function(){} );
	} else if(sUnit != null && Entities.IsAlive( sUnit ) ){
		if(!$("#targetPanelMain").visible){
			$("#targetPanelMain").visible = true;
		}
		// target got changed, refresh name and typing
		if (prevBoss != sUnit){
			prevBoss = sUnit
			var nameMod = "_h"
			var difficulty = CustomNetTables.GetTableValue( "game_info", "difficulty" ).difficulty
			if(difficulty > 2){
				nameMod = "_vh"
			}
			var unitName = 	Entities.GetUnitName( sUnit )
			if((unitName.match(/_h/g) != null || unitName.match(/_vh/g) != null)){
				nameMod = ""
			}
			if( (nameMod != "") && ($.Localize("#" + unitName + nameMod) == unitName + nameMod) ){
				nameMod = ""
			}
			$("#bossNameLabel").text = $.Localize("#" + unitName + nameMod);
			var elite = ""
			for (var i = 0; i < Entities.GetAbilityCount( sUnit ); i++) {
				var abilityID = Entities.GetAbility( sUnit, i )
				var abilityName = 	Abilities.GetAbilityName( abilityID )
				if (abilityName.match(/elite_/g)){
					elite = elite + " " + $.Localize( "#DOTA_Tooltip_ability_" + abilityName )
					$("#bossNameLabel").text = $.Localize( "#DOTA_Tooltip_ability_" + abilityName ) + " " + $("#bossNameLabel").text
				}
			}
			$("#WildTypeIcon").visible = false;
			$("#UndeadTypeIcon").visible = false;
			$("#DemonicTypeIcon").visible = false;
			$("#CelestialTypeIcon").visible = false;
			// 1 is minion and 2 is boss, 0 is neither
			var minionType = 0
			for (var i = 0; i < Entities.GetNumBuffs(sUnit); i++) {
				var buffID = Entities.GetBuff(sUnit, i)
				if (Buffs.GetName(sUnit, buffID ) == "modifier_typing_tag" ){
					if( (Buffs.GetStackCount(sUnit, buffID ) & BH_MINION_TYPE_WILD) == BH_MINION_TYPE_WILD ){
						$("#WildTypeIcon").visible = true;
					}
					if( (Buffs.GetStackCount(sUnit, buffID ) & BH_MINION_TYPE_UNDEAD) == BH_MINION_TYPE_UNDEAD ){
						$("#UndeadTypeIcon").visible = true;
					}
					if( (Buffs.GetStackCount(sUnit, buffID ) & BH_MINION_TYPE_DEMONIC) == BH_MINION_TYPE_DEMONIC ){
						$("#DemonicTypeIcon").visible = true;
					}
					if( (Buffs.GetStackCount(sUnit, buffID ) & BH_MINION_TYPE_CELESTIAL) == BH_MINION_TYPE_CELESTIAL ){
						$("#CelestialTypeIcon").visible = true;
					}
					if( ( Buffs.GetStackCount(sUnit, buffID ) & BH_MINION_TYPE_MINION) == BH_MINION_TYPE_MINION ){
						minionType = 1
					}
					if( ( Buffs.GetStackCount(sUnit, buffID ) & BH_MINION_TYPE_BOSS ) == BH_MINION_TYPE_BOSS ){
						minionType = 2
					}
				}
			}
			var minionTypeIcon = $("#MinionTypeIcon")
			if(minionType == 1){
				minionTypeIcon.SetImage("file://{images}/custom_game/icons/minionBorder.png")
				minionTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", minionTypeIcon, "This enemy is a Minion.")} );
			}else if(minionType == 2){
				minionTypeIcon.SetImage("file://{images}/custom_game/icons/bossBorder.png")
				minionTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", minionTypeIcon, "This enemy is a Boss.")} );
			} else {
				minionTypeIcon.SetImage("file://{images}/custom_game/icons/eliteBorder.png")
				minionTypeIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", minionTypeIcon, "This enemy is a Monster.")} );
			}
		};
		$("#hpBarCurrentText").text = Entities.GetHealth( sUnit ) + " / " + Entities.GetMaxHealth( sUnit );
		if(Entities.GetMaxHealth( sUnit ) > 0)
		{
			var hpPct = Entities.GetHealth( sUnit )/Entities.GetMaxHealth( sUnit ) * 100
			$("#hpBarCurrent").style.clip = "rect( 0% ," + hpPct + "%" + ", 100% ,0% )";
			
			var maxMana = Entities.GetMaxMana( sUnit )
			if(maxMana > 0){
				$("#mpBarRoot").visible = true;
				$("#mpBarCurrentText").text = Entities.GetMana( sUnit ) + " / " + maxMana;
				var manaPct = Entities.GetMana( sUnit ) / maxMana * 100
				$("#mpBarCurrent").style.clip = "rect( 0% ," + manaPct + "%" + ", 100% ,0% )";
			} else {
				$("#mpBarRoot").visible = false;
			}
		}
		var localAbility = $("#currentlyCastAbility")
		localAbility.abilityname = "generic_hidden"
		localAbility.SetHasClass("SpellActiveBorder", false)
		localAbility.SetPanelEvent("onmouseover", function(){} );
		localAbility.SetPanelEvent("onactivate", function(){} );
		for (var i = 0; i < Entities.GetAbilityCount( sUnit ); i++) {
			var ability = Entities.GetAbility( sUnit, i )
			if ( Abilities.IsInAbilityPhase( ability ) === true){
				localAbility.abilityname = Abilities.GetAbilityName( ability );
				localAbility.SetHasClass("SpellActiveBorder", true)
				localAbility.onMouseOver = function()
				{
					var queryUnit = buffHolder.heroID;
					var buffSerial = buffHolder.buffID
					var isEnemy = Entities.IsEnemy( queryUnit );
					$.DispatchEvent( "DOTAShowBuffTooltip", localAbility, queryUnit, buffSerial, isEnemy );
				}

				localAbility.onMouseOut = function()
				{
					$.DispatchEvent("DOTAHideAbilityTooltip", localAbility);
				}
				localAbility.onMouseOver = function()
				{
					$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", localAbility, localAbility.abilityname, sUnit);
				}
				localAbility.onActivate = function()
				{
					Abilities.PingAbility( ability )
				}
				localAbility.SetPanelEvent("onmouseout", localAbility.onMouseOut );
				localAbility.SetPanelEvent("onmouseover", localAbility.onMouseOver );
				localAbility.SetPanelEvent("onactivate", localAbility.onActivate );
				currBossAbility = localAbility.abilityname;
				break
			}
		}
		if ( localAbility.abilityname == "generic_hidden" && currBossAbility != "generic_hidden"){
			currBossAbility = "generic_hidden";
		}
		
		
		var buffContainer = $("#buffBar");
		for( var buff of buffContainer.Children() ){
			
			if( buff != null && Buffs.GetName(sUnit, buff.buffID )  == "" && Buffs.GetParent( sUnit, buff.buffID ) != sUnit){
				buff.style.visibility = "collapse";
				buff.DeleteAsync(0)
			}
		}
		var debuffContainer = $("#debuffBar");
		for( var debuff of debuffContainer.Children() ){
			if( debuff != null && Buffs.GetName(sUnit, debuff.buffID )  == "" && Buffs.GetParent( sUnit, debuff.buffID ) != sUnit){
				debuff.style.visibility = "collapse";
				debuff.DeleteAsync(0)
			}
		}
		for (var i = 0; i < Entities.GetNumBuffs(sUnit); i++) {
			var buffID = Entities.GetBuff(sUnit, i)
			if (!Buffs.IsHidden(sUnit, buffID ) ){
				CreateMainBuff(sUnit, buffID, $("#bossNameLabel").text )
			}
		}
	}
	$.Schedule( 0.15, UpdateHealthBar )
}

function CreateMainBuff(heroID, buffID, heroName)
{
	var buffContainer = $("#buffBar");
	var debuffContainer = $("#debuffBar");
	
	var parentPanel
	var update = false
	if(Buffs.IsDebuff(heroID, buffID) ){
		parentPanel = debuffContainer
	} else {
		parentPanel = buffContainer
	}
	var buffHolder = parentPanel.FindChild( "BuffHolder"+Buffs.GetName(heroID, buffID )+ buffID )
	if (buffHolder != null){
		update = true;
	}
	var buffBorder;
	var buff;
	var stacks = Buffs.GetStackCount(heroID, buffID );
	var buffLabel;
	if( !update ){
		buffHolder = $.CreatePanel( "Panel", parentPanel, "BuffHolder"+Buffs.GetName(heroID, buffID )+ buffID);
		buffHolder.AddClass("PlayerInfoModifierHolder")
		buffHolder.heroID = heroID;
		buffHolder.buffID = buffID;
		buffHolder.heroName = heroName
		buffHolder.buffName = $.Localize( "#DOTA_Tooltip_" + Buffs.GetName(heroID, buffID ) )
		buffHolder.hittest = true;
		
		var ability = Buffs.GetAbility(heroID, buffID );
		if( !Abilities.IsItem( ability ) ){
			buff = $.CreatePanel( "DOTAAbilityImage", buffHolder, "Buff"+Buffs.GetName(heroID, buffID )+ buffID);
			buff.abilityname = Abilities.GetAbilityName( ability );
		} else{
			buff = $.CreatePanel( "DOTAItemImage", buffHolder, "Buff"+Buffs.GetName(heroID, buffID )+ buffID);
			buff.itemname = Abilities.GetAbilityName( ability );
		}
		
		buffBorder =  $.CreatePanel( "Panel", buffHolder, "BuffBorder"+Buffs.GetName(heroID, buffID )+ buffID);
		buff.AddClass("PlayerMainModifier")
		if(Buffs.IsDebuff(heroID, buffID) ){
			buffBorder.AddClass("IsDebuff")
		} else {
			buffBorder.AddClass("IsBuff")
		}
		buffHolder.onMouseOver = function()
		{
			var queryUnit = buffHolder.heroID;
			var buffSerial = buffHolder.buffID
			var isEnemy = Entities.IsEnemy( queryUnit );
			$.DispatchEvent( "DOTAShowBuffTooltip", buffHolder, queryUnit, buffSerial, isEnemy );
		}

		buffHolder.onMouseOut = function()
		{
			$.DispatchEvent( "DOTAHideBuffTooltip", buffHolder );
		}
		
		buffHolder.onActivate = function()
		{
			var ID = Players.GetLocalPlayer()
			GameEvents.SendCustomGameEventToServer( "bh_notify_modifier", { pID: ID, unitname : buffHolder.heroName, buffname : buffHolder.buffName, duration : ( Buffs.GetRemainingTime(buffHolder.heroID, buffHolder.buffID ) ).toFixed(1)} );
		}
		
		buffHolder.SetPanelEvent("onmouseover", buffHolder.onMouseOver );
		buffHolder.SetPanelEvent("onmouseout", buffHolder.onMouseOut );
		buffHolder.SetPanelEvent("onactivate", buffHolder.onActivate );
	} else {
		buff = buffHolder.GetChild( 0 )
		buffBorder = buffHolder.GetChild( 1 )
		buffLabel =  buff.FindChild( "BuffLabel"+Buffs.GetName(heroID, buffID )+ buffID);
	}
	var completion = Math.max( 0, 360 * (Buffs.GetRemainingTime(heroID, buffID ) / Buffs.GetDuration(heroID, buffID )) )
	if(Buffs.GetDuration( heroID, buffID ) == -1 || Buffs.GetRemainingTime(heroID, buffID ) < 0){ completion = 360; }
	buffBorder.style.clip = "radial(50% 50%, 0deg, " + completion + "deg)";
	var stacks = Buffs.GetStackCount(heroID, buffID )
	if(stacks > 0 && buffLabel == null){
		var buffLabel =  $.CreatePanel( "Label", buff, "BuffLabel"+Buffs.GetName(heroID, buffID )+ buffID);
		buffLabel.AddClass("PlayerMainModifierLabel")
		buffLabel.text = stacks
	} else if(stacks > 0 && buffLabel.text != stacks) {
		buffLabel.text = stacks
	}
}

GameEvents.Subscribe( "Update_threat", update_threat);
function update_threat(arg)
{
	var threat = arg.threat.toFixed(1);
	$("#threatLabel").text = threat.toString();
	if (arg.aggro != null && arg.aggro == 1){
		$("#threatLabel").style.color = "#FF0000"
	} else if (arg.aggro != null && arg.aggro == 2){
		$("#threatLabel").style.color = "#FF8100"
	} else {
		$("#threatLabel").style.color= "#2FFF00"
	}
}

function tell_threat()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Tell_Threat", { pID: ID} );
}
