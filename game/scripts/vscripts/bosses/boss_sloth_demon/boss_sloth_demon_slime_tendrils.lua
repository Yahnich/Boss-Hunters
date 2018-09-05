boss_sloth_demon_slime_tendrils = class({})

function boss_sloth_demon_slime_tendrils:GetIntrinsicModifierName()
	return "modifier_boss_sloth_demon_slime_tendrils"
end

modifier_boss_sloth_demon_slime_tendrils = class({})
LinkLuaModiifier( "modifier_boss_sloth_demon_slime_tendrils", "bosses/boss_sloth_demon/boss_sloth_demon_slime_tendrils", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_tendrils:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_sloth_demon_slime_tendrils:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_sloth_demon_slime_tendrils:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKE_DAMAGE}
end

function modifier_boss_sloth_demon_slime_tendrils:OnTakeDamage(params)
	if params.attacker == self:GetParent() then
		params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_boss_sloth_demon_slime_tendrils_debuff", {duration = self.duration} )
	end
end

modifier_boss_sloth_demon_slime_tendrils_debuff = class({})
LinkLuaModiifier( "modifier_boss_sloth_demon_slime_tendrils_debuff", "bosses/boss_sloth_demon/boss_sloth_demon_slime_tendrils", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_tendrils_debuff:OnCreated()
	self.ms = self:GetSpecialValueFor("move_slow")
	self.ts = self:GetSpecialValueFor("turn_slow")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:OnRefresh()
	self.ms = self:GetSpecialValueFor("move_slow")
	self.ts = self:GetSpecialValueFor("turn_slow")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:DeclareFunctions()
	return {TURNSLOW, MOVESLOW}
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:DeclareFunctions()
	return self.ts
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:DeclareFunctions()
	return self.ms
end