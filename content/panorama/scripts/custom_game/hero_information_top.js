"use strict";

function FindModifierByName( entityIndex, modifierName ){
	var buffs = Entities.GetNumBuffs( entityIndex )
	for( var i=0;i<buffs;i++){
		var buff = Entities.GetBuff( entityIndex, i )
		var buffName = Buffs.GetName( entityIndex, buff );
		if (buffName == modifierName){
			return buff
		}
	}
}

(function UpdatePartyHealthBars()
{
	if( !Game.IsGamePaused()){
		var partyContainer = $.GetContextPanel();
		var nLocalPlayerID = Game.GetLocalPlayerID();
		var nLocalPlayerTeam = DOTATeam_t.DOTA_TEAM_GOODGUYS;

		var PlayerIDs = Game.GetPlayerIDsOnTeam( nLocalPlayerTeam );
		var i = 0;
		var netTable = CustomNetTables.GetAllTableValues( "hero_properties" )
		var threatOrder = {};
		var orderedThreat = []
		for( entIndex in netTable ){
			var entindex = netTable[entIndex].key
			var data = netTable[entIndex].value
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
			var playerID = PlayerIDs[ i ];
			var playerPanelName = "PartyPortrait" + i;
			var entIndex = Players.GetPlayerHeroEntityIndex( playerID );
			var playerInfo = Game.GetPlayerInfo( playerID );
			var playerPanel = partyContainer.FindChild( playerPanelName );
			if ( playerPanel === null )
			{
				playerPanel = $.CreatePanel( "Panel", partyContainer, playerPanelName );
				playerPanel.BLoadLayoutSnippet("HeroInformationContainer")
				
				var livesIcon = playerPanel.FindChildTraverse( "HeroInformationLivesButton" )
				livesIcon.playerID = playerID
				livesIcon.entIndex = entIndex
				livesIcon.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", livesIcon, $.Localize( "#LivesInfoSnippet", livesIcon) );});
				livesIcon.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", livesIcon)} );
				livesIcon.SetPanelEvent("onactivate", function(){
					var lifeLabel = playerPanel.FindChildTraverse( "TotalLivesLabel" )
					var livesText = "I have " + lifeLabel.text + " lives."
					if( livesIcon.playerID != Players.GetLocalPlayer() ){
						livesText = $.Localize( Entities.GetUnitName( livesIcon.entIndex ), livesIcon ) + " has " + lifeLabel.text + " lives."
					}
					GameEvents.SendCustomGameEventToServer( "Tell_Threat", {threatText: livesText } );
				});
				
				var lifeLabel = playerPanel.FindChildTraverse( "TotalLivesLabel" );
				lifeLabel.text = Buffs.GetStackCount( entIndex, livesHandler )
				
				var threatButton = playerPanel.FindChildTraverse( "HeroInformationButton" )
				threatButton.playerID = playerID
				threatButton.entIndex = entIndex
				threatButton.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", threatButton, $.Localize( "#ThreatInfoSnippet", threatButton))} );
				threatButton.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", threatButton)} );
				threatButton.SetPanelEvent("onactivate", function(){
					var threatLabel = playerPanel.FindChildTraverse( "HeroThreatLabel" )
					var threatText = "I have " + threatLabel.text + " threat."
					if( threatButton.playerID != Players.GetLocalPlayer() ){
						threatText = $.Localize( Entities.GetUnitName( threatButton.entIndex ), threatButton ) + " has " + threatLabel.text + " threat."
					}
					GameEvents.SendCustomGameEventToServer( "Tell_Threat", {threatText: threatText } );
				});
			}

			if ( entIndex === -1 )
				continue;
			
			playerPanel.SetAttributeInt( "player_id", playerID );
			
			var heroImage = playerPanel.FindChildTraverse( "HeroImage" );
			heroImage.heroname = Players.GetPlayerSelectedHero( playerID );
			var heroIconContainer = playerPanel.FindChildTraverse( "HeroInformationHeroImageContainer" );
			heroIconContainer.SetAttributeInt( "ent_index", entIndex );
			heroIconContainer.SetAttributeInt( "player_id", playerID );
			
			var livesHandler = FindModifierByName( entIndex , "modifier_lives_handler" )

			var healthBar = playerPanel.FindChildTraverse( "HealthBar" );
			healthBar.value = Entities.GetHealthPercent( entIndex );
			var manaBar = playerPanel.FindChildTraverse( "ManaBar" );
			manaBar.value = 100.0 * (Entities.GetMana( entIndex ) / Entities.GetMaxMana( entIndex ) );

			var bDead = !Entities.IsAlive( entIndex );
			heroIconContainer.SetHasClass( "Dead", bDead );
			var respawnLabel = playerPanel.FindChildTraverse( "RespawnTimerLabel" );
			respawnLabel.text = Players.GetRespawnSeconds( playerID )
			
			if(livesHandler != null){
				var lifeLabel = playerPanel.FindChildTraverse( "TotalLivesLabel" );
				lifeLabel.text = Buffs.GetStackCount( entIndex, livesHandler )
			}
			
			var threatLabel = playerPanel.FindChildTraverse( "HeroThreatLabel" )
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

			var bDisconnected = playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED || playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED;
			playerPanel.SetHasClass( "Disconnected", bDisconnected )
		
		}
	}
	$.Schedule( 1.0/3.0, UpdatePartyHealthBars );
})();