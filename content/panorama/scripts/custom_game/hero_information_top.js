"use strict";

function FindModifierByName( entityIndex, modifierName ){
	let buffs = Entities.GetNumBuffs( entityIndex )
	for( let i=0;i<buffs;i++){
		let buff = Entities.GetBuff( entityIndex, i )
		let buffName = Buffs.GetName( entityIndex, buff );
		if (buffName == modifierName){
			return buff
		}
	}
}

(function UpdatePartyHealthBars()
{
	if( !Game.IsGamePaused()){
		let partyContainer = $.GetContextPanel();
		let nLocalPlayerID = Game.GetLocalPlayerID();
		let nLocalPlayerTeam = DOTATeam_t.DOTA_TEAM_GOODGUYS;

		let PlayerIDs = Game.GetPlayerIDsOnTeam( nLocalPlayerTeam );
		let i = 0;
		let netTable = CustomNetTables.GetAllTableValues( "hero_properties" )
		let threatOrder = {};
		let orderedThreat = []
		for( let index in netTable ){
			let entindex = netTable[index].key
			let data = netTable[index].value
			if( data != null && data.threat != null){
				threatOrder[entindex] = data.threat
				orderedThreat.push( data.threat )
			} else {
				threatOrder[entindex] = 0
				orderedThreat.push( 0.0 )
			}
		}
		orderedThreat.sort( function(a, b){return b-a} );
		for ( i; i < PlayerIDs.length; i++ )
		{
			let playerID = PlayerIDs[ i ];
			let playerPanelName = "PartyPortrait" + i;
			let entIndex = Players.GetPlayerHeroEntityIndex( playerID );
			let playerInfo = Game.GetPlayerInfo( playerID );
			let playerPanel = partyContainer.FindChild( playerPanelName );
			if ( playerPanel === null )
			{
				playerPanel = $.CreatePanel( "Panel", partyContainer, playerPanelName );
				playerPanel.BLoadLayoutSnippet("HeroInformationContainer")
				playerPanel.playerID = playerID;
				playerPanel.hittest = true
				playerPanel.SetPanelEvent("onactivate", function(){
					GameUI.SelectUnit( Players.GetPlayerHeroEntityIndex( playerPanel.playerID ), false )
				})
				playerPanel.SetPanelEvent("ondblclick", function(){
					GameUI.MoveCameraToEntity( Players.GetPlayerHeroEntityIndex( playerPanel.playerID ) )
				})
				
				let livesIcon = playerPanel.FindChildTraverse( "HeroInformationLivesButton" )
				livesIcon.playerID = playerID
				livesIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", livesIcon, $.Localize( "#LivesInfoSnippet", livesIcon) );});
				livesIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", livesIcon)} );
				livesIcon.SetPanelEvent("onactivate", function(){
					let lifeLabel = playerPanel.FindChildTraverse( "TotalLivesLabel" )
					let livesText = "%%#" + Entities.GetUnitName( Players.GetPlayerHeroEntityIndex( livesIcon.playerID ) ) + "%%"
							   + ' <img src="file://{images}/control_icons/chat_wheel_icon.png" style="width:8px;height:8px" width="8" height="8" > '
							   + lifeLabel.text + " %%#BOSSHUNTERS_CurrentLives%%"
					GameEvents.SendCustomGameEventToServer( "server_dota_push_to_chat", {PlayerID : Players.GetLocalPlayer(), textData : livesText, isTeam : true} )
				});
				
				let threatButton = playerPanel.FindChildTraverse( "HeroInformationButton" )
				threatButton.playerID = playerID
				threatButton.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", threatButton, $.Localize( "#ThreatInfoSnippet", threatButton))} );
				threatButton.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", threatButton)} );
				threatButton.SetPanelEvent("onactivate", function(){
					let threatLabel = playerPanel.FindChildTraverse( "HeroThreatLabel" )
					let threatText = "%%#" + Entities.GetUnitName( Players.GetPlayerHeroEntityIndex( threatButton.playerID ) ) + "%%"
							   + ' <img src="file://{images}/control_icons/chat_wheel_icon.png" style="width:8px;height:8px" width="8" height="8" > '
							   + threatLabel.text + " %%#BOSSHUNTERS_CurrentThreat%%"
					GameEvents.SendCustomGameEventToServer( "server_dota_push_to_chat", {PlayerID : Players.GetLocalPlayer(), textData : threatText, isTeam : true} )
				});
			}

			if ( entIndex === -1 )
				continue;
			
			let livesHandler = FindModifierByName( entIndex , "modifier_lives_handler" )
			playerPanel.SetAttributeInt( "player_id", playerID );
			
			let heroImage = playerPanel.FindChildTraverse( "HeroImage" );
			heroImage.heroname = Players.GetPlayerSelectedHero( playerID );
			let heroIconContainer = playerPanel.FindChildTraverse( "HeroInformationHeroImageContainer" );
			heroIconContainer.SetAttributeInt( "ent_index", entIndex );
			heroIconContainer.SetAttributeInt( "player_id", playerID );
			
			let healthBar = playerPanel.FindChildTraverse( "HealthBar" );
			healthBar.value = Entities.GetHealthPercent( entIndex );
			let manaBar = playerPanel.FindChildTraverse( "ManaBar" );
			manaBar.value = 100.0 * (Entities.GetMana( entIndex ) / Entities.GetMaxMana( entIndex ) );

			let bDead = !Entities.IsAlive( entIndex );
			heroIconContainer.SetHasClass( "Dead", bDead );
			let respawnLabel = playerPanel.FindChildTraverse( "RespawnTimerLabel" );
			respawnLabel.text = Players.GetRespawnSeconds( playerID )
			
			if(livesHandler != null){
				let lifeLabel = playerPanel.FindChildTraverse( "TotalLivesLabel" );
				lifeLabel.text = Buffs.GetStackCount( entIndex, livesHandler )
			}
			
			let threatLabel = playerPanel.FindChildTraverse( "HeroThreatLabel" )
			if( threatOrder[entIndex] != null ){
				threatLabel.text = threatOrder[entIndex].toFixed(1)
				if( orderedThreat[0] != null && orderedThreat[0] == threatOrder[entIndex] ){
					threatLabel.style.color = "#FF0000"
				} else if( orderedThreat[1] != null && orderedThreat[1] == threatOrder[entIndex] ) {
					threatLabel.style.color = "#FF8100"
				} else {
					threatLabel.style.color = "#2FFF00"
				}
			} else {
				threatLabel.text = '0.0'
			}
			heroImage.style.washColor = bDead ? "#990000" : "#FFFFFF";	

			let bDisconnected = playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED || playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED;
			playerPanel.SetHasClass( "Disconnected", bDisconnected )
		
		}
	}
	$.Schedule( 1.0/3.0, UpdatePartyHealthBars );
})();