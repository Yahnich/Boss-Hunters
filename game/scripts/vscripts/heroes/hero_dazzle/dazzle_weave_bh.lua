dazzle_weave_bh = class({})

function dazzle_weave_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local targetPos = self:GetCursorPosition()
	
	local radius = target:GetHullRadius() + target:GetCollisionPadding()
	local duration = self:GetTalentSpecialValueFor("duration")
	
	target:EmitSound("Hero_Dazzle.Weave")
	ParticleManager:FireParticle("particles/units/heroes/hero_dazzle/dazzle_weave.vpcf", PATTACH_ABSORIGIN, target, {[1] = Vector(radius,0 ,0 )})
	
	target:AddNewModifier(caster, self, "modifier_dazzle_weave_bh", {duration = duration})
end

modifier_dazzle_weave_bh = class({})
LinkLuaModifier("modifier_dazzle_weave_bh", "heroes/hero_dazzle/dazzle_weave_bh", 0)

function modifier_dazzle_weave_bh:OnCreated()
	self.armor_per_tick = self:GetTalentSpecialValueFor("armor_per_second")
	self.armor = 0
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_weave_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_weave_2")
	self:StartIntervalThink(1)
end

function modifier_dazzle_weave_bh:OnIntervalThink()
	self.armor = self.armor + self.armor_per_tick
end

function modifier_dazzle_weave_bh:IsDebuff()
	return ( not self:GetParent():IsSameTeam( self:GetCaster() ) )
end

function modifier_dazzle_weave_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_dazzle_weave_bh:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return self.armor
	else
		return self.armor * -1
	end
end

function modifier_dazzle_weave_bh:OnAbilityExecuted(params)
	if self.talent1 and params.unit == self:GetCaster() and params.ability == "dazzle_shadow_wave_bh" then
		params.ability:ApplyEffects( self:GetParent() )
	end
end

function modifier_dazzle_weave_bh:GetModifierHealAmplify_Percentage()
	if not self.talent2 then return end
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return self.armor
	else
		return self.armor * -1
	end
end

function modifier_dazzle_weave_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_armor_dazzle.vpcf"
end

function modifier_dazzle_weave_bh:GetEffectName()
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return "particles/units/heroes/hero_dazzle/dazzle_armor_friend.vpcf"
	else
		return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf"
	end
end

function modifier_dazzle_weave_bh:StatusEffectPriority()
	return 3
end

function modifier_dazzle_weave_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end