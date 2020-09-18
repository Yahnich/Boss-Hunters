undying_flesh_golem_bh = class({})

function undying_flesh_golem_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function undying_flesh_golem_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_undying_flesh_golem_bh", {duration = self:GetTalentSpecialValueFor("duration")})
	caster:StartGesture( ACT_DOTA_SPAWN )
	EmitSoundOn("Hero_Undying.FleshGolem.Cast", caster )
end

modifier_undying_flesh_golem_bh = class({})
LinkLuaModifier("modifier_undying_flesh_golem_bh", "heroes/hero_undying/undying_flesh_golem_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_flesh_golem_bh:OnCreated()
	self:OnRefresh()
end

function modifier_undying_flesh_golem_bh:OnRefresh()
	self.bonus_strength = self:GetTalentSpecialValueFor("bonus_strength")
	self.bonus_ms = self:GetTalentSpecialValueFor("bonus_ms")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal")
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_undying_flesh_golem_1")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_undying_flesh_golem_1", "value2")
	self.threat = self:GetCaster():FindTalentValue("special_bonus_unique_undying_flesh_golem_1", "value3")
	self:GetCaster():HookInModifier("GetModifierLifestealBonus", self)
	self:GetCaster():HookInModifier("GetModifierStrengthBonusPercentage", self)
end

function modifier_undying_flesh_golem_bh:OnDestroy()
	self:GetCaster():HookOutModifier("GetModifierLifestealBonus", self)
	self:GetCaster():HookOutModifier("GetModifierStrengthBonusPercentage", self)
	if IsServer() then
		EmitSoundOn( "Hero_Undying.FleshGolem.End", self:GetCaster() )
	end
end

function modifier_undying_flesh_golem_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			}
end

function modifier_undying_flesh_golem_bh:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_undying_flesh_golem_2") then
		if self:RollPRNG( self:GetParent():FindTalentValue("special_bonus_unique_undying_flesh_golem_2") ) then
			params.target:Fear(self:GetAbility(), self:GetCaster(), self:GetCaster():FindTalentValue("special_bonus_unique_undying_flesh_golem_2", "duration") )
		end
	end
end

function modifier_undying_flesh_golem_bh:GetModifierStrengthBonusPercentage()
	return self.bonus_strength
end

function modifier_undying_flesh_golem_bh:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_undying_flesh_golem_bh:GetModifierLifestealBonus()
	return self.lifesteal
end

function modifier_undying_flesh_golem_bh:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_undying_flesh_golem_bh:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_undying_flesh_golem_bh:Bonus_ThreatGain()
	return self.threat
end

function modifier_undying_flesh_golem_bh:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_undying_flesh_golem_bh:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end