boss_evil_guardian_purge_their_sin = class({})

function boss_evil_guardian_purge_their_sin:GetIntrinsicModifierName()
	return "modifier_boss_evil_guardian_purge_their_sin_handler"
end

modifier_boss_evil_guardian_purge_their_sin_handler = class({})
LinkLuaModifier("modifier_boss_evil_guardian_purge_their_sin_handler", "bosses/boss_evil_guardian/boss_evil_guardian_purge_their_sin", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_evil_guardian_purge_their_sin_handler:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end


function modifier_boss_evil_guardian_purge_their_sin_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_evil_guardian_purge_their_sin_handler:OnTakeDamage( params )
	if params.attacker == self:GetParent() then
		params.unit:AddNewModifier(params.attacker, self:GetAbility(), "modifier_boss_evil_guardian_purge_their_sin_debuff", {duration = self.duration})
		ParticleManager:FireParticle("particles/units/heroes/hero_jakiro/jakiro_macropyre_firehit.vpcf", PATTACH_POINT_FOLLOW, params.unit)
	end
end

function modifier_boss_evil_guardian_purge_their_sin_handler:IsHidden()
	return true
end

function modifier_boss_evil_guardian_purge_their_sin_handler:GetEffectName()
	return "particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient.vpcf"
end

modifier_boss_evil_guardian_purge_their_sin_debuff = class({})
LinkLuaModifier("modifier_boss_evil_guardian_purge_their_sin_debuff", "bosses/boss_evil_guardian/boss_evil_guardian_purge_their_sin", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_evil_guardian_purge_their_sin_debuff:OnCreated()
	self.amp = self:GetSpecialValueFor("damage_amp")
	self:SetStackCount(1)
end

function modifier_boss_evil_guardian_purge_their_sin_debuff:OnRefresh()
	self.amp = self:GetSpecialValueFor("damage_amp")
	self:IncrementStackCount()
end

function modifier_boss_evil_guardian_purge_their_sin_debuff:GetEffectName()
	return "particles/units/bosses/boss_evil_guardian/boss_evil_guardian_purge_their_sin_debuff.vpcf"
end

function modifier_boss_evil_guardian_purge_their_sin_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_evil_guardian_purge_their_sin_debuff:GetModifierIncomingDamage_Percentage( params )
	return self.amp * self:GetStackCount()
end