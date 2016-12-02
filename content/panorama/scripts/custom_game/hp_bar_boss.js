var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$("#hp_bar_general").visible = false
$("#hp_bar_shield").visible = false


GameEvents.Subscribe( "Update_Health_Bar", update_hp_bar)
GameEvents.Subscribe( "Update_mana_Bar", update_mana_bar)
GameEvents.Subscribe( "Update_threat", update_threat)
GameEvents.Subscribe( "Close_Health_Bar", close_HB)
GameEvents.Subscribe( "Open_Health_Bar", open_HB)
GameEvents.Subscribe( "disactivate_shield", desactivate_shield)
GameEvents.Subscribe( "activate_shield", activate_shield)
	function close_HB()
	{
		if (team < 3)
		{
			$("#hp_bar_general").visible = false;
		}
	}
	function open_HB()
	{
		if (team < 3)
			{
				$("#hp_bar_general").visible = true;
			}
	}

	function desactivate_shield()
	{
		$("#hp_bar_shield").visible = false;
	}
	
	function activate_shield()
	{
		$("#hp_bar_shield").visible = true;
	}
	
	function update_mana_bar(arg)
	{
		$("#hp_bar_parent_mana").style.clip = "rect( 0% ," + ((arg.current_mana/arg.total_mana)*63.1+27.0) + "%" + ", 100% ,0% )";
	}
	function update_hp_bar(arg)
	{
		$("#hp_bar_parent_health").style.clip = "rect( 0% ," + ((arg.current_life/arg.total_life)*77.3+22.7) + "%" + ", 100% ,0% )";
		$("#hp_bar_current").text = arg.current_life;
		$("#hp_bar_total").text = arg.total_life;
		$("#hp_bar_name").text = $.Localize("#"+arg.name);
		$.Msg($("#hp_bar_name").text)
	}

		

