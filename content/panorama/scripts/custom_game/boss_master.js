var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$.Msg('Team ID',team)
	if (team < 3)
	{
		$('#'+"boss_master").visible = false; 
		GameUI.SetCameraDistance( 2000 )
	}

	function SendEvent_Boss_Master(commandname)
	{
		var iPlayerID = Players.GetLocalPlayer();
		$.Msg('send event to server !');
		GameEvents.SendCustomGameEventToServer( "Boss_Master", { pID: iPlayerID , Command: commandname} );
	}

		

