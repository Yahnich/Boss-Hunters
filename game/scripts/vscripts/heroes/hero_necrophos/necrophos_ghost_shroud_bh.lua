necrophos_ghost_shroud_bh = class({})

function necrophos_ghost_shroud_bh:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_necrophos_ghost_shroud_bh") then
		self:SetCooldown()
		caster:RemoveModifierByName("modifier_necrophos_ghost_shroud_bh")
	else
		caster:AddNewModifier( caster, self, "modifier_necrophos_ghost_shroud_bh", {duration = self:GetTalentSpecialValueFor("duration")})
		ProjectileManager:ProjectileDodge( caster )
		self:EndCooldown()
	end
end

modifier_necrophos_ghost_shroud_bh = class({})
LinkLuaModifier( "modifier_necrophos_ghost_shroud_bh", "heroes/hero_necrophos/necrophos_ghost_shroud_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_ghost_shroud_bh:OnCreated()
	self.heal_amp = self:GetTalentSpecialValueFor("heal_bonus")
	self.radius = self:GetTalentSpecialValueFor("slow_aoe")
	self.minus_mr = self:GetTalentSpecialValueFor("bonus_damage")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_necrophos_ghost_shroud_1")
	if self.talent1 then
		self.duration = self:GetTalentSpecialValueFor("special_bonus_unique_necrophos_ghost_shroud_1")
	end
end

function modifier_necrophos_ghost_shroud_bh:CheckState()
	return {[MODIFIER_STATE_DISARMED] = not self.talent1,
			[MODIFIER_STATE_ATTACK_IMMUNE] = not self.talent1,}
end

function modifier_necrophos_ghost_shroud_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_necrophos_ghost_shroud_bh:OnAttackLanded(params)
	if self.talent1 and params.attacker == self:GetParent() then
		params.target:DisableHealing(self.duration)
	end
end

function modifier_necrophos_ghost_shroud_bh:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_necrophos_ghost_shroud_bh:GetModifierMagicalResistanceBonus()
	return self.minus_mr
end

function modifier_necrophos_ghost_shroud_bh:GetModifierHealAmplify_Percentage()
	return self.heal_amp
end

function modifier_necrophos_ghost_shroud_bh:IsAura()
	return true
end

function modifier_necrophos_ghost_shroud_bh:GetModifierAura()
	return "modifier_necrophos_ghost_shroud_bh_slow"
end

function modifier_necrophos_ghost_shroud_bh:GetAuraRadius()
	return self.radius
end

function modifier_necrophos_ghost_shroud_bh:GetAuraDuration()
	return 0.5
end

function modifier_necrophos_ghost_shroud_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_necrophos_ghost_shroud_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_necrophos_ghost_shroud_bh:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_necrophos_ghost_shroud_bh_slow = class({})
LinkLuaModifier( "modifier_necrophos_ghost_shroud_bh_slow", "heroes/hero_necrophos/necrophos_ghost_shroud_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_ghost_shroud_bh_slow:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("movement_speed") * (-1)
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_necrophos_ghost_shroud_2")
	if self.talent2 then
		self.dmg = self:GetCaster:FindTalentValue("special_bonus_unique_necrophos_ghost_shroud_2") / 100
		self:StartIntervalThink(1)
	end
end

function modifier_necrophos_ghost_shroud_bh_slow:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetCaster():GetIntellect() * self.dmg, {damage_type = DAMAGE_TYPE_MAGICAL damage_flags = DOTA_DAMAGE_FLAGS_NO_SPELL_AMPLIFICATION} )
end