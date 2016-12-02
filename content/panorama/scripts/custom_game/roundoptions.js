function No()
{
	HideButtons('You voted no.');
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Vote_Round", { pID: ID,vote: false} );
}

function HideButtons(text)
{
	$("#Vote_Yes").visible = false;
	$("#confirmation").text = text;
	$("#confirmation").visible = true;
}

function Yes()
{
	HideButtons('You voted yes.');
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Vote_Round", { pID: ID,vote: true} );
}
GameEvents.Subscribe( "RoundVoteResults", updateVoteResults)
GameEvents.Subscribe( "Display_RoundVote", open)
GameEvents.Subscribe( "Close_RoundVote", close)

$("#RoundOptions").visible = false;


function open()
{
		$("#Vote_Yes").visible = true;
	$("#confirmation").visible = false;
	$("#RoundOptions").visible = true;
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
	$("#RoundOptions").visible = false;
}