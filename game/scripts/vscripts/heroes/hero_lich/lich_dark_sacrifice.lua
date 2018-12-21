lich_dark_sacrifice = class({})

function lich_dark_sacrifice:GetCooldown( iLvl )
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("scepter_cooldown")
	else
		return self.BaseClass.GetCooldown( self, iLvl )
	end
end

function lich_dark_sacrifice:GetManaCost( iLvl )
	if self:GetCaster():HasScepter() then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function lich_dark_sacrifice:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local hpPct = self:GetTalentSpecialValueFor("curr_health_dmg") / 100
	local convHp = self:GetTalentSpecialValueFor("health_conversion") / 100
	local duration = self:GetTalentSpecialValueFor("duration")
	
	local targetHealth = target:GetHealth()
	local target_damage = targetHealth * hpPct
	local damage = 0
	self:DealDamage( caster, target, target_damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	damage = targetHealth - target:GetHealth()
	ParticleManager:FireParticle("particles/units/heroes/hero_lich/lich_dark_sacrifice_target.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_lich/lich_dark_ritual.vpcf", PATTACH_POINT_FOLLOW, target, caster)
	target:EmitSound("Ability.DarkRitual")
	
	local restoration = damage * convHp
	local buff = caster:AddNewModifier( caster, self, "modifier_lich_dark_sacrifice", {duration = duration})
	if buff then
		buff:SetStackCount(restoration)
		caster:CalculateStatBonus()
		caster:RestoreMana( restoration )
		caster:HealEvent( restoration, self, caster )
	end
end

modifier_lich_dark_sacrifice = class({})
LinkLuaModifier("modifier_lich_dark_sacrifice", "heroes/hero_lich/lich_dark_sacrifice", LUA_MODIFIER_MOTION_NONE )

function modifier_lich_dark_sacrifice:OnCreated()
	self.cdr = self:GetCaster():FindTalentValue("special_bonus_unique_lich_dark_sacrifice_2")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_lich_dark_sacrifice_1")
	if self.talent1 then
		self.chill = self:GetCaster():FindTalentValue("special_bonus_unique_lich_dark_sacrifice_1")
	end
end

function modifier_lich_dark_sacrifice:OnRefresh()
	self.cdr = self:GetCaster():FindTalentValue("special_bonus_unique_lich_dark_sacrifice_2")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_lich_dark_sacrifice_1")
	if self.talent1 then
		self.chillAmt = self:GetCaster():FindTalentValue("special_bonus_unique_lich_dark_sacrifice_1")
		self.chillDur = self:GetCaster():FindTalentValue("special_bonus_unique_lich_dark_sacrifice_1", "duration")
	end
end

function modifier_lich_dark_sacrifice:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_PROPERTY_EXTRA_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_lich_dark_sacrifice:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

function modifier_lich_dark_sacrifice:GetModifierExtraManaBonus()
	return self:GetStackCount()
end

function modifier_lich_dark_sacrifice:GetCooldownReduction()
	return self.cdr
end

function modifier_lich_dark_sacrifice:OnAttackLanded(params)
	if self.talent1 and params.attacker == self:GetParent() then
		params.target:AddChill(self:GetAbility(), self:GetCaster(), self.chillDur, self.chillAmt)
	end
end