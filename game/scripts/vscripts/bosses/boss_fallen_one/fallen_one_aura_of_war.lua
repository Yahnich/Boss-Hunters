fallen_one_aura_of_war = class({})

function fallen_one_aura_of_war:GetIntrinsicModifierName()
	return "modifier_fallen_one_aura_of_war"
end

modifier_fallen_one_aura_of_war = class({})
LinkLuaModifier( "modifier_fallen_one_aura_of_war", "bosses/boss_fallen_one/fallen_one_aura_of_war", LUA_MODIFIER_MOTION_NONE )

function modifier_fallen_one_aura_of_war:OnCreated()
end


modifier_fallen_one_aura_of_war_buff = class({})
LinkLuaModifier( "modifier_fallen_one_aura_of_war_buff", "bosses/boss_fallen_one/fallen_one_aura_of_war", LUA_MODIFIER_MOTION_NONE )