GameEvents.Subscribe( "Update_Midas_gold", UpdateMidas);
function UpdateMidas(arg)
{
	if (typeof arg != 'undefined') {
		$("#midas_gold_display").text = arg.gold + " ( +" + arg.interest + " )";
	}
}

		

