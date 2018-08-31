boss_alpha_wolf_howl = class({})

function boss_alpha_wolf_howl:OnSpellStart()
	local caster = self:GetCaster()
	
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		ally:AddNewModifier( caster, self, "modifier_boss_alpha_wolf_howl", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_boss_alpha_wolf_howl = class({})
LinkLuaModifier("modifier_boss_alpha_wolf_howl", "bosses/boss_wolves/boss_alpha_wolf_howl", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_alpha_wolf_howl:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	self.health = self:GetSpecialValueFor("health") / 100
	if IsServer() then
		local bonusHealth = self:GetParent():GetMaxHealth() * self.health
		self:SetStackCount(bonusHealth)
		self:GetParent():HealEvent( bonusHealth, self:GetAbility(), self:GetCaster() )
	end
end

function modifier_boss_alpha_wolf_howl:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
	self.health = self:GetSpecialValueFor("health") / 100
	if IsServer() then
		local bonusHealth = self:GetParent():GetMaxHealth() * self.health
		self:SetStackCount(bonusHealth)
		self:GetParent():HealEvent( bonusHealth, self:GetAbility(), self:GetCaster() )
	end
end

function modifier_boss_alpha_wolf_howl:DeclareFunctions()
	return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE }
end

function modifier_boss_alpha_wolf_howl:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

function modifier_boss_alpha_wolf_howl:GetModifierDamageOutgoing_Percentage()
	return self.damage
end