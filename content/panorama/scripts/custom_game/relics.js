RELIC_TYPE_GENERIC = 1
RELIC_TYPE_CURSED = 2
RELIC_TYPE_UNIQUE = 3

var localID = Players.GetLocalPlayer()

function SelectRelic(type)
{
	var relicTable = CustomNetTables.GetTableValue( "relics", "relic_drops")
	var playerRelics = relicTable[localID]
	if(type == RELIC_TYPE_GENERIC){
		
	} else if(type == RELIC_TYPE_CURSED){
		
	} else if(type == RELIC_TYPE_UNIQUE){
		
	}
}

function SkipRelics()
{
	
}