
injectPanel()
function injectPanel(){
	var parentPanel = $.GetContextPanel(); // the root panel of the current XML context
	var newChildPanel = $.CreatePanel( "Panel", parentPanel, "ChildPanelID" );
	newChildPanel.BLoadLayout( "file://{resources}/layout/custom_game/new_panel.xml", false, false );
}