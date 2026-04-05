generic_basic = class({})

function generic_basic:Spawn()
	CustomGameEventManager:RegisterListener('dota_player_talent_info_request', Context_Wrap( TalentManager, 'ParseInformationRequest'))
end

function generic_basic:OnUpgrade()
	
end