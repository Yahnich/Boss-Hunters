GameEvents.Subscribe( "player_update_stats", UpdateStats);
GameEvents.Subscribe( "player_update_gold", UpdateGold);
GameEvents.Subscribe( "round_has_ended", ToggleStats);

function UpdateGold(arg)
{
	if (typeof arg != 'undefined') {
		$("#midasGoldLabel").text = arg.gold + " Total\n ( +" + arg.interest + " This round)";
	}
}

function UpdateStats(arg)
{
	if (typeof arg != 'undefined') {
		for( pID in arg ){
			UpdateList(pID, "DT", Math.floor(arg[pID].DT + 0.5) )
			UpdateList(pID, "DD", Math.floor(arg[pID].DD + 0.5) )
			UpdateList(pID, "DH", Math.floor(arg[pID].DH + 0.5) )
		}
	}
}

function UpdateList(pID, tag, value)
{
	var PIDtag = $("#pID" + pID + tag)
	var holder = $("#" + tag + "Holder")
	if(PIDtag == null && holder != null){
		PIDtag = $.CreatePanel( "Label", holder, "pID" + pID + tag);
		PIDtag.AddClass("statsText")
	}
	var heroName = $.Localize( Entities.GetUnitName( Players.GetPlayerHeroEntityIndex( parseInt(pID) ) ) )
	PIDtag.text = heroName + " - " + value 
}

function ToggleStats(arg)
{
	var teamInfo = $("#endRoundStats")
	var midasGold = $("#MGHolder")
	if(arg != null)
	{
		teamInfo.SetHasClass("SetHidden", false )
		midasGold.SetHasClass("SetHidden", false )
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
	} else {
		teamInfo.SetHasClass("SetHidden", !(teamInfo.BHasClass("SetHidden")) )
		midasGold.SetHasClass("SetHidden", (teamInfo.BHasClass("SetHidden")) )
		if(teamInfo.BHasClass("SetHidden")){
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideRight.png")
		} else {
			$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
		}
	}
}