boss_genesis_pacifism = class({})

function boss_genesis_pacifism:GetIntrinsicModifierName()
	return "modifier_boss_genesis_pacifism"
end

function boss_genesis_pacifism:ShouldUseResources()
	return true
end

modifier_boss_genesis_pacifism = class({})
LinkLuaModifier( "modifier_boss_genesis_pacifism", "bosses/boss_genesis/boss_genesis_pacifism", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_pacifism:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_genesis_pacifism:OnTakeDamage(params)
	local ability = self:GetAbility()
	if params.unit == self:GetParent() and ability:IsCooldownReady() then
		local duration = self:GetSpecialValueFor("duration")
		params.attacker:Disarm( params.unit, ability, duration)
		params.attacker:Silence( params.unit, ability, duration)
		ability:SetCooldown
	end
end