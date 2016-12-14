var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$('#'+"midas_gold").visible = false;
$('#'+"midas_gold_open").visible = false;
$('#'+"midas_gold_close").visible = false;
var open = true
	function create_gold_display()
	{
		if (team < 3)
		{
			$('#'+"midas_gold_close").visible = true;
			$('#'+"midas_gold").visible = true;
		}
	}
GameEvents.Subscribe( "Update_Midas_gold", UpdateMidas);
	function UpdateMidas(arg)
	{
		if (typeof arg != 'undefined') {
		if (open){
			open_gold()
		}else{
			close_gold()
		}
			$('#'+"midas_gold_earned").text = arg.gold;
		}
	}
	
	function open_gold()
	{	
		open = true
		$('#'+"midas_gold_open").visible = false;
		$('#'+"midas_gold_close").visible = true;
		$('#'+"midas_gold").visible = true;
	}
	
	function close_gold()
	{
		open = false
		$('#'+"midas_gold_open").visible = true;
		$('#'+"midas_gold_close").visible = false;
		$('#'+"midas_gold").visible = false;
	}

		

