boss_genesis_deconstruction = class({})

function boss_genesis_deconstruction:GetIntrinsicModifierName()
	return "modifier_boss_genesis_deconstruction"
end

modifier_boss_genesis_deconstruction = class({})
LinkLuaModifier( "modifier_boss_genesis_deconstruction", "bosses/boss_genesis/boss_genesis_deconstruction", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_deconstruction:IsAura()
	return true
end

function modifier_boss_genesis_deconstruction:GetModifierAura()
	return "modifier_boss_genesis_deconstruction_debuff"
end

function modifier_boss_genesis_deconstruction:GetAuraRadius()
	return self:GetSpecialValueFor("radius")
end

function modifier_boss_genesis_deconstruction:GetAuraDuration()
	return 0.5
end

function modifier_boss_genesis_deconstruction:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_genesis_deconstruction:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_genesis_deconstruction:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_boss_genesis_deconstruction_debuff = class({})
LinkLuaModifier( "modifier_boss_genesis_deconstruction_debuff", "bosses/boss_genesis/boss_genesis_deconstruction", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_deconstruction_debuff:DeclareFunctions()
	return {}
end

function modifier_boss_genesis_deconstruction_debuff:Gethealthregne()
	if self:GetCaster():HasModifier("modifier_boss_genesis_strengthen_resolve") then
		return self:GetSpecialValueFor("regen")
	else
		return self:GetSpecialValueFor("regen_buff")
	end
end