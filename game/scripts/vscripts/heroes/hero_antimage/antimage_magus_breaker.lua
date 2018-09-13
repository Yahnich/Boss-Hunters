antimage_magus_breaker = class ({})

function antimage_magus_breaker:GetIntrinsicModifierName()
	return "modifier_antimage_magus_breaker"
end

modifier_antimage_magus_breaker = class({})
LinkLuaModifier( "modifier_antimage_magus_breaker", "heroes/hero_antimage/antimage_magus_breaker", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_magus_breaker:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage_on_hit")
	self.stack_damage = self:GetTalentSpecialValueFor("stack_damage")
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_antimage_magus_breaker:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage_on_hit")
	self.stack_damage = self:GetTalentSpecialValueFor("stack_damage")
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_antimage_magus_breaker:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE}
end

function modifier_antimage_magus_breaker:GetModifierProcAttack_BonusDamage_Pure(params)
	local damage = self.damage
	local caster = self:GetCaster()
	params.target:AddNewModifier(caster, self:GetAbility(), "modifier_antimage_magus_breaker_debuff", {duration = self.duration})
	if params.target:GetModifierStackCount("modifier_antimage_magus_breaker_debuff", caster) > 0 then
		damage = damage + self.stack_damage * params.target:GetModifierStackCount("modifier_antimage_magus_breaker_debuff", caster)
		params.target:EmitSound("Hero_Antimage.ManaBreak")
		ParticleManager:FireParticle("particles/mage_rage.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
	end
	return damage
end

function modifier_antimage_magus_breaker:IsHidden()
	return true
end

modifier_antimage_magus_breaker_debuff = class({})
LinkLuaModifier( "modifier_antimage_magus_breaker_debuff", "heroes/hero_antimage/antimage_magus_breaker", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_magus_breaker_debuff:OnCreated()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_1")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_2")
	self.duration = self:GetTalentSpecialValueFor("duration")
	if IsServer() then
		self:SetStackCount( 1 )
	end
end

function modifier_antimage_magus_breaker_debuff:OnRefresh()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_1")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_2")
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_antimage_magus_breaker_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_antimage_magus_breaker_debuff:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		self:IncrementStackCount()
	end
end

function modifier_antimage_magus_breaker_debuff:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end

function modifier_antimage_magus_breaker_debuff:GetModifierMagicalResistanceBonus()
	return self.mr * self:GetStackCount()
end