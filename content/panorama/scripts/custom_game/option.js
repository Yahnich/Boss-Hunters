var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$("#DPS_main").visible = false;
		var HB_State = true;
		var dps_State = false;
		$('#'+"option_unmute_sound").visible = false; 
		$('#'+"option_close").visible = false; 
		$('#'+"option_general").visible = false; 

		function mute_sound()
		{
			$("#option_mute_sound").visible = false;
			$("#option_unmute_sound").visible = true;
			var iPlayerID = Players.GetLocalPlayer();
			$.Msg('Player ID mute ');
			GameEvents.SendCustomGameEventToServer( "mute_sound", { pID: iPlayerID} );
		}
		
		function unmute_sound()
		{
			$("#option_mute_sound").visible = true;
			$("#option_unmute_sound").visible = false;
			var iPlayerID = Players.GetLocalPlayer();
			$.Msg('Player ID unmute ');
			GameEvents.SendCustomGameEventToServer( "unmute_sound", { pID: iPlayerID} );
		}
		function switch_HB()
		{
			if (HB_State)
			{
				HB_State = false;
				$("#hp_bar_general").visible = false;
				$('#'+"text_HB").text = "Enable Custom HealthBar";
			}
			else
			{
				HB_State = true;
				$("#hp_bar_general").visible = true;
				$('#'+"text_HB").text = "Disable Custom HealthBar";
				
			}
		}
		function switch_dps()
		{
			if (dps_State)
			{
				dps_State = false;
				$("#DPS_main").visible = false;
				$('#'+"text_DPS").text = "Enable DPS Meter";
			}
			else
			{
				dps_State = true;
				$("#DPS_main").visible = true;
				$('#'+"text_DPS").text = "Disable DPS Meter";
			}
		}
		function open_option()
		{
			$("#option_general").visible = true;
			$("#option_close").visible = true;
			$("#option_open").visible = false;
		}
		function close_option()
		{
			$("#option_general").visible = false;
			$("#option_close").visible = false;
			$("#option_open").visible = true;
		}


		
GameEvents.Subscribe( "Update_threat", update_threat);
function update_threat(arg)
{
	var threat = arg.threat.toFixed(1);
	$("#threat_bar_amount").text = threat.toString();
	if (arg.aggro != null && arg.aggro == 1){
		$("#threat_bar_amount").style.color = "#FF0000"
	} else if (arg.aggro != null && arg.aggro == 2){
		$("#threat_bar_amount").style.color = "#FF8100"
	} else {
		$("#threat_bar_amount").style.color= "#2FFF00"
	}
}

function tell_threat()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Tell_Threat", { pID: ID} );
}


UpdateHB()

function UpdateHB(){
$.Schedule(0.025, UpdateHB);

	data = CustomNetTables.GetTableValue( "HB", "HB")
	if (typeof data != 'undefined') {
		if (data.HP == 0 ){ $("#hp_bar_general").visible = false}
		$("#hp_bar_parent_health").style.clip = "rect( 0% ," + ((data.HP/data.Max_HP)*77.3+22.7) + "%" + ", 100% ,0% )";
		$("#hp_bar_current").text = Number((data.HP).toFixed(0));
		$("#hp_bar_total").text = Number((data.Max_HP).toFixed(0));
		$("#hp_bar_name").text = data.elite + $.Localize("#" + data.Name);
		if (data.Max_MP != 0){
			$("#hp_bar_parent_mana").style.clip = "rect( 0% ," + ((data.MP/data.Max_MP)*63.1+27.0) + "%" + ", 100% ,0% )";
		} else{
			$("#hp_bar_parent_mana").style.clip = "rect( 0% , 100%, 100% ,0% )";
		}
		if (data.shield == 1){
			$("#hp_bar_shield").visible = true;
		}else { $("#hp_bar_shield").visible = false;}
		
		if (HB_State) {
			$("#hp_bar_general").visible = true;
		} else { $("#hp_bar_general").visible = false}

	} else { $("#hp_bar_general").visible = false}
}
	UpdateDPS()

function UpdateDPS(){
	$.Schedule(0.025, UpdateDPS);
	key = "player_" + ID.toString()
	data = CustomNetTables.GetTableValue( "Damage", key)
	if (typeof data != 'undefined') {
		$("#damage").text = Number((data.Hero_Damage).toFixed(0));;
		$("#TD").text = Number((data.Team_Damage).toFixed(0));
		var time = Game.GetGameTime()
		var dps = (data.Hero_Damage/(time - data.First_hit))
		$("#DPS").text = Number((dps).toFixed(2));
	}
	
}

		
		