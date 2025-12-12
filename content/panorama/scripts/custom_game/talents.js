// DEFAULT HUD INITIALIZATION
const mainHud = $.GetContextPanel().GetParent().GetParent().GetParent()
const DOTAHud = mainHud.FindChildTraverse("HUDElements")
const lowerHud = DOTAHud.FindChildTraverse("lower_hud")
var talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var levelUp = lowerHud.FindChildTraverse("level_stats_frame")

var localID = Players.GetLocalPlayer()
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )

lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "collapse";

GameEvents.Subscribe("dota_player_gained_level", RequestNewPanelData);
GameEvents.Subscribe("dota_player_learned_ability", RequestNewPanelData);
GameEvents.Subscribe("dota_player_update_query_unit", CheckUnitChanged);
GameEvents.Subscribe("dota_player_update_selected_unit", CheckUnitChanged);
GameEvents.Subscribe("dota_player_talent_info_response", ProcessTalentResponse);
GameEvents.Subscribe("dota_player_talent_update_failure", ServerResponded);

if(lastRememberedHero != -1){
	RequestNewPanelData()
} 

var serverRequestInProgress = false

function ServerResponded(){
	hasQueuedAction = false;
	serverRequestInProgress = false;
}

function CheckUnitChanged( eventData ){
	hasQueuedAction = false
	if(lastRememberedHero != Players.GetLocalPlayerPortraitUnit()){
		RequestNewPanelData()
	}
}

function RequestNewPanelData( eventData ){
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if(eventData != null && eventData.hero_entindex != null && eventData.hero_entindex != lastRememberedHero){return}
	if( eventData != null && eventData.PlayerID != null && Players.GetPlayerHeroEntityIndex( eventData.PlayerID ) != lastRememberedHero){return}
	if( Entities.IsRealHero( lastRememberedHero ) && !serverRequestInProgress){
		serverRequestInProgress = true
		GameEvents.SendCustomGameEventToServer( "dota_player_talent_info_request", {pID : localID, entindex : lastRememberedHero} )	
	} else {
		PerformTalentLayout( );
	}
}

function AttemptPurchaseTalent(talentName, abilityName){
	$.Msg( hasQueuedAction )
	if(!hasQueuedAction)
	{
		hasQueuedAction = true
		Game.EmitSound( "Button.Click" )
		GameEvents.SendCustomGameEventToServer( "send_player_selected_unique", {pID : localID, entindex : lastRememberedHero,  talent : talentName, abilityName : abilityName} )
	}
}

function ProcessTalentResponse( panelData ){
	$.Schedule( 0, function(){ 
		if(lowerHud.FindChildTraverse("Ability0") != null){
			PerformTalentLayout(panelData) 
		} else {
			ProcessTalentResponse( panelData )
		}
	} )
}

var vectorAbilityTable = {}
var clickBehavior = 0;
var currentlyActiveVectorTargetAbility

//Mouse Callback to check whever this ability was quick casted or not
GameUI.SetMouseCallback(function(eventName, arg, arg2, arg3)
{
	click_start = true;
	clickBehavior = GameUI.GetClickBehaviors();
	if(clickBehavior == 3 && currentlyActiveVectorTargetAbility != undefined){
		var netTable = CustomNetTables.GetTableValue( "vector_targeting", currentlyActiveVectorTargetAbility.entindex )
		OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength);
	}
	return CONTINUE_PROCESSING_EVENT;
});

function PerformTalentLayout( panelData ){
	serverRequestInProgress = false
	hasQueuedAction = false
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	let netTable
	if(panelData != null){
		netTable = panelData.response
	}
	for (i = 0; i <= 5; i++){
		let abilityCont = lowerHud.FindChildTraverse("Ability"+i)
		if(abilityCont != null){
			let abilityButton = abilityCont.FindChildTraverse("ButtonSize")
			let abilityImage = abilityCont.FindChildTraverse("AbilityImage")
			let abilityName = abilityImage.abilityname
			let abilityIndex = 	Entities.GetAbilityByName( lastRememberedHero, abilityName )
			let filteredBehavior = Abilities.GetBehavior( abilityIndex ) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
			abilityCont.isVectorTargetAbility = false
			abilityCont.entindex = abilityIndex
			if(filteredBehavior == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING){
				abilityCont.isVectorTargetAbility = true
				vectorAbilityTable[abilityCont] = true
			}
			if( abilityCont.BHasClass("AbilityMaxLevel6") ){
				let levelContainer = abilityCont.FindChildTraverse("AbilityLevelContainer")
				for( levelPip of levelContainer.Children() ){
					levelPip.style.width = "5px"
				}
			}
			let oldCont = abilityButton.FindChildTraverse("UniqueTalentContainer")
			if( oldCont != null ){
				oldCont.style.visibility = "collapse"
				oldCont.RemoveAndDeleteChildren()
				oldCont.DeleteAsync(0)
			}
			if(netTable != null && netTable.uniqueTalents != null && lastRememberedHero == panelData.entindex){
				let talentContainer = $.CreatePanel("Panel", $.GetContextPanel(), "UniqueTalentContainer");
				talentContainer.BLoadLayoutSnippet("TalentContainer")
				talentContainer.SetParent(abilityButton)
				
				let talentIndex = 1
				
				talentContainer.FindChildTraverse("UniqueTalent1").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent2").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent3").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent4").AddClass("IsHidden")
				talentContainer.FindChildTraverse("UniqueTalent5").AddClass("IsHidden")
				for(let talent in netTable.uniqueTalents[abilityName]){
					let talentPhase = 0
					if ( netTable.uniqueTalents[abilityName][talent] == -1 ){
						talentPhase = 1
					} else if( Players.GetPlayerHeroEntityIndex( localID ) == lastRememberedHero && Abilities.GetLevel( abilityIndex ) > 0 && netTable.uniqueTalents[abilityName][talent] <= Entities.GetLevel( lastRememberedHero ) && panelData.talentPoints > 0){
						talentPhase = 2
					}
					AddTalentToAbilityButton(talentContainer, talent, talentIndex, talentPhase, abilityName )
					talentIndex++;
				}
			}
		}
	}
}

$.RegisterForUnhandledEvent( "StyleClassesChanged", CheckAbilityVectorTargeting );

function CheckAbilityVectorTargeting( table ){
	if( table == null ){return}
	if( table.isVectorTargetAbility == true ){
		if( table.hasBeenMarkedActivated && !table.BHasClass( "is_active" )){
			table.hasBeenMarkedActivated = false
			currentlyActiveVectorTargetAbility = undefined
			OnVectorTargetingEnd( false )
		} else if( !table.hasBeenMarkedActivated && table.BHasClass( "is_active" ) ) {
			table.hasBeenMarkedActivated = true
			currentlyActiveVectorTargetAbility = table
			if( GameUI.GetClickBehaviors() == 9 ){
				var netTable = CustomNetTables.GetTableValue( "vector_targeting", table.entindex )
				OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength);
			}
		}
	}
}

///// Vector Targeting
var CONSUME_EVENT = true;
var CONTINUE_PROCESSING_EVENT = false;

//main variables
var active_ability = undefined;
var vector_target_particle = undefined;
var vectorTargetUnit = undefined;
var vector_start_position = undefined;
var mouseClickBlocker = undefined;
var vector_range = 800;
var click_start = false;
var resetSchedule;
var is_quick = false;
var vectorTargetUnit;


// Start the vector targeting
function OnVectorTargetingStart(fStartWidth, fEndWidth, fCastLength)
{
	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var mainSelectedName = Entities.GetUnitName(mainSelected);
	vectorTargetUnit = mainSelected;
	var cursor = GameUI.GetCursorPosition();
	var worldPosition = GameUI.GetScreenWorldPosition(cursor);
	// particle variables
	var startWidth = fStartWidth || 125
	var endWidth = fEndWidth || startWidth
	vector_range = fCastLength || 800
	//Initialize the particle
	var casterLoc = Entities.GetAbsOrigin(mainSelected);
	var testPos = [casterLoc[0] + Math.min( 1500, vector_range), casterLoc[1], casterLoc[2]];
	vector_target_particle = Particles.CreateParticle("particles/ui_mouseactions/range_finder_cone.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, mainSelected);
	vectorTargetUnit = mainSelected
	Particles.SetParticleControl(vector_target_particle, 1, Vector_raiseZ(worldPosition, 100));
	Particles.SetParticleControl(vector_target_particle, 2, Vector_raiseZ(testPos, 100));
	Particles.SetParticleControl(vector_target_particle, 3, [endWidth, startWidth, 0]);
	Particles.SetParticleControl(vector_target_particle, 4, [0, 255, 0]);

	//Calculate initial particle CPs
	vector_start_position = worldPosition;
	var unitPosition = Entities.GetAbsOrigin(mainSelected);
	var direction = Vector_normalize(Vector_sub(vector_start_position, unitPosition));
	var newPosition = Vector_add(vector_start_position, Vector_mult(direction, vector_range));
	Particles.SetParticleControl(vector_target_particle, 2, newPosition);
	
	// mouseClickBlocker = $.CreatePanel( "Button", $.GetContextPanel(), "MouseClickBlockerVectorTargeting");
	// mouseClickBlocker.style.width = "100%";
	// mouseClickBlocker.style.height = "100%";
	//Start position updates
	ShowVectorTargetingParticle();
	return CONTINUE_PROCESSING_EVENT;
}

//End the particle effect
function OnVectorTargetingEnd(bSend)
{
	if (vector_target_particle) {
		Particles.DestroyParticleEffect(vector_target_particle, true)
		vector_target_particle = undefined;
		vectorTargetUnit = undefined;
	}
}

//Updates the particle effect and detects when the ability is actually casted
function ShowVectorTargetingParticle()
{
	if (vector_target_particle !== undefined)
	{
		var mainSelected = Players.GetLocalPlayerPortraitUnit();
		var cursor = GameUI.GetCursorPosition();
		var worldPosition = GameUI.GetScreenWorldPosition(cursor);

		if (worldPosition == null)
		{
			$.Schedule(1 / 144, ShowVectorTargetingParticle);
			return;
		}
		var val = Vector_sub(worldPosition, vector_start_position);
		if (!(val[0] == 0 && val[1] == 0 && val[2] == 0))
		{
			var direction = Vector_normalize(Vector_sub(vector_start_position, worldPosition));
			direction = Vector_flatten(Vector_negate(direction));
			var newPosition = Vector_add(vector_start_position, Vector_mult(direction, vector_range));

			Particles.SetParticleControl(vector_target_particle, 2, newPosition);
		}
		if( mainSelected != vectorTargetUnit ){
			GameUI.SelectUnit( vectorTargetUnit, false )
		}
		$.Schedule(1 / 144, ShowVectorTargetingParticle);
	}
}

//Some Vector Functions here:
function Vector_normalize(vec)
{
	var val = 1 / Math.sqrt(Math.pow(vec[0], 2) + Math.pow(vec[1], 2) + Math.pow(vec[2], 2));
	return [vec[0] * val, vec[1] * val, vec[2] * val];
}

function Vector_mult(vec, mult)
{
	return [vec[0] * mult, vec[1] * mult, vec[2] * mult];
}

function Vector_add(vec1, vec2)
{
	return [vec1[0] + vec2[0], vec1[1] + vec2[1], vec1[2] + vec2[2]];
}

function Vector_sub(vec1, vec2)
{
	return [vec1[0] - vec2[0], vec1[1] - vec2[1], vec1[2] - vec2[2]];
}

function Vector_negate(vec)
{
	return [-vec[0], -vec[1], -vec[2]];
}

function Vector_flatten(vec)
{
	return [vec[0], vec[1], 0];
}

function Vector_raiseZ(vec, inc)
{
	return [vec[0], vec[1], vec[2] + inc];
}

function AddTalentToAbilityButton( talentContainer, talentName, talentIndex, talentPhase, abilityName ){
	let talent = talentContainer.FindChildTraverse("UniqueTalent"+talentIndex)
	talent.RemoveClass("IsHidden")
	let notLocalHero = Entities.GetPlayerOwnerID( lastRememberedHero ) != localID
	let baseText = ""
	if( notLocalHero ) {
		baseText = "%%#" + Entities.GetUnitName( lastRememberedHero ) + '%%'
				   + ' > '
	}
	if( talentPhase == 1 ){
		talent.AddClass("Learned")
		talent.SetPanelEvent("onactivate", function(){
			if(GameUI.IsAltDown()){
				let talentText = baseText + "%%" + "#DOTA_Tooltip_Ability_" + talentName + "%%" + " (%%#DOTA_Talent_HasLearned%%)"
							   + ' > '
							   + "%%" + ("#DOTA_Tooltip_Ability_" + talentName+"_Description") + "%%"
				GameEvents.SendCustomGameEventToServer( "server_dota_push_to_chat", {PlayerID : localID, textData : talentText, isTeam : true, abilityID : Entities.GetAbilityByName( lastRememberedHero, talentName )} )
			}
			
		})
	} else if ( talentPhase == 2 ) {
		talent.AddClass("LevelReady")
		talent.SetPanelEvent("onactivate", function(){
			$.DispatchEvent("DOTAHideAbilityTooltip", talent)
			if(!GameUI.IsAltDown()){
				talent.SetPanelEvent("onactivate", function(){})
				AttemptPurchaseTalent(talentName, abilityName)
			} else {
				let talentText = baseText + "%%" + "#DOTA_Tooltip_Ability_" + talentName + "%%" + " (%%#DOTA_Talent_CanBeLearned%%)"
							   + ' > '
							   + "%%" + ("#DOTA_Tooltip_Ability_" + talentName+"_Description") + "%%"
				GameEvents.SendCustomGameEventToServer( "server_dota_push_to_chat", {PlayerID : localID, textData : talentText, isTeam : true, abilityID : Entities.GetAbilityByName( lastRememberedHero, talentName )} )
			}} );
			
	} else {
		talent.SetPanelEvent("onactivate", function(){
			if(GameUI.IsAltDown()){
				let talentText = baseText + "%%" + "#DOTA_Tooltip_Ability_" + talentName + "%%" + " (%%#DOTA_Talent_CannotBeLearned%%)" 
							   + ' > '
							   + "%%" + ("#DOTA_Tooltip_Ability_" + talentName+"_Description") + "%%"
				GameEvents.SendCustomGameEventToServer( "server_dota_push_to_chat", {PlayerID : localID, textData : talentText, isTeam : true, abilityID : Entities.GetAbilityByName( lastRememberedHero, talentName )} )
			}
		})
	}
	talent.SetPanelEvent("onmouseover", function(){
		$.DispatchEvent("DOTAShowAbilityTooltip", talent, talentName )
	})
	talent.SetPanelEvent("onmouseout", function(){
		talent.RemoveClass("Highlighted")
		$.DispatchEvent("DOTAHideAbilityTooltip", talent);
	});
}