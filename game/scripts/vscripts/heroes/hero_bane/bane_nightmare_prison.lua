bane_nightmare_prison = class({})

function bane_nightmare_prison:OnSpellStart()
	local modifierName = "modifier_bane_nightmare_prison_sleep"
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetTalentSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_bane_nightmare_prison_2") then
		modifierName = "modifier_bane_nightmare_prison_fear"
	end
	EmitSoundOn("Hero_Bane.Nightmare", target)
	if target:TriggerSpellAbsorb(self) then return end
	target:RemoveModifierByName( modifierName )
	target:AddNewModifier(caster, self, modifierName, {duration = duration})
end


modifier_bane_nightmare_prison_sleep = class({})
LinkLuaModifier("modifier_bane_nightmare_prison_sleep", "heroes/hero_bane/bane_nightmare_prison", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_nightmare_prison_sleep:OnCreated()
	self.minDuration = self:GetTalentSpecialValueFor("min_duration")
	self.damage = self:GetTalentSpecialValueFor("damage")
	if IsServer() then 
		self:StartIntervalThink(1)
		EmitSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
	end
end

function modifier_bane_nightmare_prison_sleep:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		StopSoundOn("Hero_Bane.Nightmare.Loop", parent)
		EmitSoundOn("Hero_Bane.Nightmare.End", parent)
		
		self:GetAbility():DealDamage( caster, parent, self:GetTalentSpecialValueFor("burst_damage") )
		if caster:HasTalent("special_bonus_unique_bane_nightmare_prison_2") then
			parent:AddNewModifier(caster, self:GetAbility(), "modifier_bane_nightmare_prison_fear", {duration = caster:FindTalentValue("special_bonus_unique_bane_nightmare_prison_2", "duration")} )
		end
	end
end

function modifier_bane_nightmare_prison_sleep:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_bane_nightmare_prison_sleep:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_bane_nightmare_prison_sleep:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetElapsedTime() > self.minDuration and params.attacker ~= self:GetCaster() then
		self:Destroy()
	end
end

function modifier_bane_nightmare_prison_sleep:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_bane_nightmare_prison_sleep:GetOverrideAnimationRate()
	return 0.2
end


function modifier_bane_nightmare_prison_sleep:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function modifier_bane_nightmare_prison_sleep:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_bane_nightmare_prison_sleep:GetStatusEffectName()
	return "particles/status_fx/status_effect_nightmare.vpcf"
end

function modifier_bane_nightmare_prison_sleep:StatusEffectPriority()
	return 10
end

function modifier_bane_nightmare_prison_sleep:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NIGHTMARED] = true,
			[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
			[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
			}
end

modifier_bane_nightmare_prison_fear = class({})
LinkLuaModifier("modifier_bane_nightmare_prison_fear", "heroes/hero_bane/bane_nightmare_prison", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_nightmare_prison_fear:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_bane_nightmare_prison_2")
	self.blind = self:GetCaster():FindTalentValue("special_bonus_unique_bane_nightmare_prison_2","value2")
end

function modifier_bane_nightmare_prison_fear:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function modifier_bane_nightmare_prison_fear:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_bane_nightmare_prison_fear:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_bane_nightmare_prison_fear:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_bane_nightmare_prison_fear:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end