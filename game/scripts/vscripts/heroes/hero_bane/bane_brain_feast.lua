bane_brain_feast = class({})

function bane_brain_feast:GetIntrinsicModifierName()
	return "modifier_bane_brain_feast_autocast"
end

function bane_brain_feast:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasScepter() then cd = self:GetTalentSpecialValueFor("scepter_cooldown") end
	return cd
end

function bane_brain_feast:GetManaCost(iLvl)
	local mc = self.BaseClass.GetManaCost(self, iLvl)
	if self:GetCaster():HasScepter() then mc = mc * self:GetTalentSpecialValueFor("scepter_mana_cost") end
	return mc
end

function bane_brain_feast:GetCastPoint()
	if self:GetCaster():HasScepter() then
		return 0.15
	else
		return 0.5
	end
end

function bane_brain_feast:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Bane.BrainSap.Target", target)
	EmitSoundOn("Hero_Bane.BrainSap", caster)
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_POINT_FOLLOW, caster, target)
	if target:TriggerSpellAbsorb(self) then return end
	
	local damage = self:GetTalentSpecialValueFor("heal_damage")
	if not target.IsNightmared then 
		target.IsNightmared = function() return ( target:HasModifier("modifier_bane_nightmare_prison_sleep") or target:HasModifier("modifier_bane_nightmare_prison_fear") ) end
	end
	if caster:HasTalent("special_bonus_unique_bane_brain_feast_1") and target:IsNightmared() then
		damage = damage * caster:FindTalentValue("special_bonus_unique_bane_brain_feast_1")
	end
	local heal = self:DealDamage(caster, target, damage)
	caster:HealEvent(heal, self, caster)
	

	if caster:HasTalent("special_bonus_unique_bane_brain_feast_2") then
		target:AddNewModifier(caster, self, "modifier_bane_brain_feast_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
	end
end

modifier_bane_brain_feast_autocast = class({})
LinkLuaModifier("modifier_bane_brain_feast_autocast", "heroes/hero_bane/bane_brain_feast", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_brain_feast_autocast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_bane_brain_feast_autocast:OnAttack(params)
	if params.attacker == self:GetParent() and self:GetAbility():GetAutoCastState() and self:GetAbility():IsFullyCastable() then
		params.attacker:CastAbilityOnTarget( params.target, self:GetAbility(), params.attacker:GetPlayerID() )
	end
end

function modifier_bane_brain_feast_autocast:IsHidden()
	return true
end

modifier_bane_brain_feast_debuff = class({})
LinkLuaModifier("modifier_bane_brain_feast_debuff", "heroes/hero_bane/bane_brain_feast", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_brain_feast_debuff:OnCreated()
	self.slow = -self:GetCaster():GetIntellect( false)
end

function modifier_bane_brain_feast_debuff:OnRefresh()
	self:OnRefresh()
end

function modifier_bane_brain_feast_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_bane_brain_feast_debuff:GetModifierMoveSpeedBonus_Constant()
	return self.slow
end

function modifier_bane_brain_feast_debuff:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_brain_feast_debuff.vpcf"
end

function modifier_bane_brain_feast_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end