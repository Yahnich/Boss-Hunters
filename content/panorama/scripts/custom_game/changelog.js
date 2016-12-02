"use strict";

$("#changelogButton").visible = false;
var inNG = false;
Update();

function Update(){
$.Schedule(1, Update);
CustomNetTables.SubscribeNetTableListener
	var data = CustomNetTables.GetTableValue( "New_Game_plus", "NG")
	if (typeof data != 'undefined') {
	if (data.NG == 1 && inNG == false){ $("#changelogButton").visible = true;
						$("#descriptionDisplay").visible = true;
						$("#updateDisplay").visible = false;
						$("#creditsDisplay").visible = false;
						$("#showDescriptionButton").checked = true;
					   $("#changelogDisplay").SetHasClass("changelogDisplayHidden", !$("#changelogDisplay").BHasClass("changelogDisplayHidden"));
					   inNG = true
		}
	}
}

function BuyItem(item,price,componement)
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Demon_Shop", { pID: ID , item_name: item, price: price,item_recipe: componement } );
}

function BuyCore()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Asura_Core", { pID: ID} );
}

function BuyPerk(perk, price, pricegain)
{
	var ID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( ID );
	var ability = Entities.GetAbilityByName( hero, perk );
	var level = 1;
	if(Abilities.GetLevel(ability) != null && Abilities.GetLevel(ability) > 0){
		level = Abilities.GetLevel(ability);
	}
	var actualprice = (price + pricegain*(level-1));
	GameEvents.SendCustomGameEventToServer( "Buy_Perk", { pID: ID , perk_name: perk, price: actualprice, pricegain: pricegain} );
}

GameEvents.Subscribe( "Update_perk", UpdatePerkPrice);
function UpdatePerkPrice(arg){
	var ID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( ID );
	var ability = Entities.GetAbilityByName( hero, perk );
	var level = 1;
	if(Abilities.GetLevel(ability) != null && Abilities.GetLevel(ability) > 0){
		level = Abilities.GetLevel(ability);
	}
	var newprice = (arg.price + arg.pricegain);
	var perk = "#" + arg.perk.toString();
	var perklevel = perk + "Level";
	$(perk).text = newprice.toString() + " Asura Cores";
	$(perklevel).text = "Lv. " + arg.level.toString();
	
}


function toggleChangelog(arg){
	$("#changelogDisplay").SetHasClass("changelogDisplayHidden", !$("#changelogDisplay").BHasClass("changelogDisplayHidden"))

	if (arg) { //shortcut to open panel and select specific tab
		arg();
	}
}

function toggleDescription(arg){
	$("#descriptionDisplay").visible = true
	$("#updateDisplay").visible = false
	$("#creditsDisplay").visible = false
	$("#showDescriptionButton").checked = true;
}

function toggleUpdates(arg){
	$("#descriptionDisplay").visible = false
	$("#updateDisplay").visible = true
	$("#creditsDisplay").visible = false
	$("#showUpdatesButton").checked = true;
}