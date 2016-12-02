
function No()
{
	HideButtons('You voted no.');
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Vote_NG", { pID: ID,vote: false} );
}

function HideButtons(text)
{
	$("#Vote_Yes").visible = false;
	$("#Vote_No").visible = false;
	$("#confirmation").text = text;
	$("#confirmation").visible = true;
	$("#yesheader").visible = true;
	$("#noheader").visible = true;
}

function Yes()
{
	HideButtons('You voted yes.');
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Vote_NG", { pID: ID,vote: true} );
}
GameEvents.Subscribe( "VoteResults", updateVoteResults)
GameEvents.Subscribe( "Display_Vote", open)
GameEvents.Subscribe( "Close_Vote", close)
GameEvents.Subscribe( "refresh_time", refresh)
$("#Vote").visible = false;
$("#confirmation").visible = false;
$("#yesheader").visible = false;
$("#noheader").visible = false;
function open()
{
	$("#Vote").visible = true;
}
function updateVoteResults(event)
{
	var noText = " vote";
	var yesText = " vote";
	
	if (event.No != 1)
	{
		noText += "s";
	}
	if (event.Yes != 1)
	{
		yesText += "s";
	}
	
	$("#noresults").text = event.No + noText;
	$("#yesresults").text = event.Yes + yesText;
}
function close()
{
	$("#Vote").visible = false;
}
function refresh(arg)
{
	$("#time_nb").text = arg.time;
}

