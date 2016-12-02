var ID = Players.GetLocalPlayer()
$("#Asura_Core").visible = false;


Update()

function Update(){
$.Schedule(0.5, Update);
CustomNetTables.SubscribeNetTableListener
	data = CustomNetTables.GetTableValue( "New_Game_plus", "NG")
	core = 0
	key2 = ""
	if (typeof data != 'undefined') {
		if (data.NG == 1){ 
			$("#Asura_Core").visible = true;
			key2 = "player_" + ID.toString()
			if(CustomNetTables.GetTableValue( "Asura_core", key2) != null){
				core = CustomNetTables.GetTableValue( "Asura_core", key2).core
			}
		}
	}
	if (typeof core != 'undefined') {
	$("#core_number").text = core;
	
	}
}

function tell_core()
	{
		var ID = Players.GetLocalPlayer()
		GameEvents.SendCustomGameEventToServer( "Tell_Core", { pID: ID} );
	}