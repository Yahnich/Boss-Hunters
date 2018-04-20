bane_nightmare_prison = class({})

function bane_nightmare_prison:OnSpellStart()
	local modifierName = "bane_nightmare_prison_sleep"
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetTalentSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_bane_nightmare_prison_2") then
		modifierName = "bane_nightmare_prison_fear"
	end
	target:AddNewModifier(caster, self, modifierName, {duration = duration})

	EmitSoundOn("Hero_Bane.Nightmare", target)
end


bane_nightmare_prison_sleep = class({})
LinkLuaModifier("bane_nightmare_prison_sleep", "heroes/hero_bane/bane_nightmare_prison", LUA_MODIFIER_MOTION_NONE)


function bane_nightmare_prison_sleep:OnCreated()
	self.minDuration = self:GetTalentSpecialValueFor("min_duration")
	self.damage = self:GetTalentSpecialValueFor("damage")
	if IsServer() then 
		self:StartIntervalThink(1)
		EmitSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
	end
end

function bane_nightmare_prison_sleep:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		StopSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
		EmitSoundOn("Hero_Bane.Nightmare.End", self:GetParent())
		if caster:HasTalent("special_bonus_unique_bane_nightmare_prison_1") then
			parent:Daze(self, caster, caster:FindTalentValue("special_bonus_unique_bane_nightmare_prison_1"))
		end
	end
end

function bane_nightmare_prison_sleep:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage)
end

function bane_nightmare_prison_sleep:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function bane_nightmare_prison_sleep:GetModifierIncomingDamage_Percentage()
	return -5
end

function bane_nightmare_prison_sleep:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetElapsedTime() > self.minDuration and params.attacker ~= self:GetCaster() then
		self:Destroy()
	end
end

function bane_nightmare_prison_sleep:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function bane_nightmare_prison_sleep:GetOverrideAnimationRate()
	return 0.2
end


function bane_nightmare_prison_sleep:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function bane_nightmare_prison_sleep:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function bane_nightmare_prison_sleep:GetStatusEffectName()
	return "particles/status_fx/status_effect_nightmare.vpcf"
end

function bane_nightmare_prison_sleep:StatusEffectPriority()
	return 10
end



function bane_nightmare_prison_sleep:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NIGHTMARED] = true,
			[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
			[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
			}
end

bane_nightmare_prison_fear = class({})
LinkLuaModifier("bane_nightmare_prison_fear", "heroes/hero_bane/bane_nightmare_prison", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function bane_nightmare_prison_fear:OnCreated()
		self:StartIntervalThink(0.2)
		self.damage = self:GetTalentSpecialValueFor("damage")
		EmitSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
	end
	
	function bane_nightmare_prison_fear:OnIntervalThink()
		local direction = CalculateDirection(self:GetParent(), self:GetCaster())
		self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + direction * self:GetParent():GetIdealSpeed() * 0.2)
		self.internal = (self.internal or 0) + 0.2
		if self.internal > 1 then
			self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage)
			self.internal = 0
		end
	end
	
	function bane_nightmare_prison_fear:OnDestroy()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		StopSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
		EmitSoundOn("Hero_Bane.Nightmare.End", self:GetParent())
		if caster:HasTalent("special_bonus_unique_bane_nightmare_prison_1") then
			parent:Daze(self, caster, caster:FindTalentValue("special_bonus_unique_bane_nightmare_prison_1"))
		end
	end
end

function bane_nightmare_prison_fear:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function bane_nightmare_prison_fear:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function bane_nightmare_prison_fear:GetStatusEffectName()
	return "particles/status_fx/status_effect_nightmare.vpcf"
end

function bane_nightmare_prison_fear:StatusEffectPriority()
	return 10
end

function bane_nightmare_prison_fear:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function bane_nightmare_prison_fear:GetModifierIncomingDamage_Percentage()
	return -5
end

function bane_nightmare_prison_fear:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end