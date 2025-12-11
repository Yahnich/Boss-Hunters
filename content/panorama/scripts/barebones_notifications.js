function TopNotification( msg ) {
  AddNotification(msg, $('#TopNotifications'));
}

function BottomNotification(msg) {
  AddNotification(msg, $('#BottomNotifications'));
}

function TopRemoveNotification(msg){
  RemoveNotification(msg, $('#TopNotifications'));
}

function BottomRemoveNotification(msg){
  RemoveNotification(msg, $('#BottomNotifications'));
}


function RemoveNotification(msg, panel){
  var count = msg.count;
  if (count > 0 && panel.GetChildCount() > 0){
    var start = panel.GetChildCount() - count;
    if (start < 0)
      start = 0;

    for (i=start;i<panel.GetChildCount(); i++){
      var lastPanel = panel.GetChild(i);
      //lastPanel.SetAttributeInt("deleted", 1);
      lastPanel.deleted = true;
      lastPanel.DeleteAsync(0);
    }
  }
}

function AddNotification(msg, panel) {
  var newNotification = true;
  var lastNotification = panel.GetChild(panel.GetChildCount() - 1)
  //$.Msg(msg)

  msg.continue = msg.continue || false;
  //msg.continue = true;

  if (lastNotification != null && msg.continue) 
    newNotification = false;

  if (newNotification){
    lastNotification = $.CreatePanel('Panel', panel, '');
    lastNotification.AddClass('NotificationLine')
    lastNotification.hittest = false;
  }

  var notification = null;
  
  if (msg.hero != null)
    notification = $.CreatePanel('DOTAHeroImage', lastNotification, '');
  else if (msg.image != null)
    notification = $.CreatePanel('Image', lastNotification, '');
  else if (msg.ability != null)
    notification = $.CreatePanel('DOTAAbilityImage', lastNotification, '');
  else if (msg.item != null)
    notification = $.CreatePanel('DOTAItemImage', lastNotification, '');
  else
    notification = $.CreatePanel('Label', lastNotification, '');

  if (typeof(msg.duration) != "number"){
    //$.Msg("[Notifications] Notification Duration is not a number!");
    msg.duration = 3
  }
  
  if (newNotification){
    $.Schedule(msg.duration, function(){
      //$.Msg('callback')
      if (lastNotification.deleted)
        return;
      
      lastNotification.DeleteAsync(0);
    });
  }

  if (msg.hero != null){
    notification.heroimagestyle = msg.imagestyle || "icon";
    notification.heroname = msg.hero
    notification.hittest = false;
  } else if (msg.image != null){
    notification.SetImage(msg.image);
    notification.hittest = false;
  } else if (msg.ability != null){
    notification.abilityname = msg.ability
    notification.hittest = false;
  } else if (msg.item != null){
    notification.itemname = msg.item
    notification.hittest = false;
  } else{
    notification.html = true;
    var text = msg.text || "No Text provided";
    notification.text = $.Localize(text)
    notification.hittest = false;
    notification.AddClass('TitleText');
  }
  
  if (msg.class)
    notification.AddClass(msg.class);
  else
    notification.AddClass('NotificationMessage');

  if (msg.style){
    for (var key in msg.style){
      var value = msg.style[key]
      notification.style[key] = value;
    }
  }
}


(function () {
	GameEvents.Subscribe( "top_notification", TopNotification );
	GameEvents.Subscribe( "bottom_notification", BottomNotification );
	GameEvents.Subscribe( "top_remove_notification", TopRemoveNotification );
	GameEvents.Subscribe( "bottom_remove_notification", BottomRemoveNotification );
	GameEvents.Subscribe( "dota_push_to_chat", CreateChatMessageInLine );

	var ID = Players.GetLocalPlayer()
	var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
	var team = Entities.GetTeamNumber( PlayerEntityIndex )
	if (team > 2)
		{
			GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );     //Shop portion of the Inventory.
			GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false );      //Entire Inventory UI
		}
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_QUICK_STATS, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, true ); 
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false );
})();

const NON_BREAKING_SPACE = "\u00A0";
const BASE_MESSAGE_INDENT = NON_BREAKING_SPACE.repeat(19);
const DOTAHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements")
// event data includes: PlayerID, isTeam and textData
function CreateChatMessageInLine(event){
	let text = BASE_MESSAGE_INDENT;
	const chatLinesPanel = DOTAHud.FindChildTraverse("ChatLinesPanel");
	const message = $.CreatePanelWithProperties("Label", chatLinesPanel, "", {
		class: "ChatLine",
		html: "true",
		selectionpos: "auto",
		hittest: "false",
		hittestchildren: "false",
	});
	message.style.flowChildren = "right";
	message.style.color = "#faeac9";
	message.style.opacity = 1;
	$.Schedule(7, () => {
		message.style.opacity = null;
	});
	
	if (event.PlayerID > -1) {
		const playerInfo = Game.GetPlayerInfo(event.PlayerID);
		const localTeamColor = "#" + intToARGB(Players.GetPlayerColor( event.PlayerID ));
		
		text += event.isTeam ? `[${$.Localize("#DOTA_ChatCommand_GameAllies_Name")}] ` : NON_BREAKING_SPACE;
		text += `<font color='${localTeamColor}'>${playerInfo.player_name}</font>: `;
		
		$.CreatePanelWithProperties("Panel", message, "", { class: "HeroBadge", selectionpos: "auto" });

		const heroIcon = $.CreatePanelWithProperties("Image", message, "", { class: "HeroIcon", selectionpos: "auto" });
		heroIcon.SetImage('file://{images}/heroes/' + playerInfo.player_selected_hero + '.png');
	} else {
		text += event.isTeam ? `[${$.Localize("#DOTA_ChatCommand_GameAllies_Name")}] ` : NON_BREAKING_SPACE;
	}

	text += event.textData.replace(/%%\d*(.+?)%%/g, (_, token) => $.Localize(token));
	if(event.abilityID != null){
		text = text.replace(/\%(\S*?)\%/g, (_, token) => {
			if(token == ""){
				return "%"
			} else {
				var level = event.abilityLevel | 1;
				return Math.abs( Abilities.GetLevelSpecialValueFor( event.abilityID, token, level ) )
			}
		});
	}
	message.text = text;
	var inlineImages = message.FindChildrenWithClassTraverse( "InlineImage" )
	for( let chatIcon of inlineImages ) {
		chatIcon.AddClass( "ChatWheelIcon" )
	}
};

function intToARGB(i) 
{ 
	return  ('00' + ( i & 0xFF).toString( 16 ) ).substr( -2 ) +
			('00' + ( ( i >> 8 ) & 0xFF ).toString( 16 ) ).substr( -2 ) +
			('00' + ( ( i >> 16 ) & 0xFF ).toString( 16 ) ).substr( -2 ) + 
			('00' + ( ( i >> 24 ) & 0xFF ).toString( 16 ) ).substr( -2 );
}