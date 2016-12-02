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
Updatemidas()
function Updatemidas(){
	$.Schedule(0.025, Updatemidas);
	data = CustomNetTables.GetTableValue( "midas", "total")
	if (typeof data != 'undefined') {
	if (open){
		open_gold()
	}else{
		close_gold()
	}
		$('#'+"midas_gold_earned").text = data.gold;
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

		

