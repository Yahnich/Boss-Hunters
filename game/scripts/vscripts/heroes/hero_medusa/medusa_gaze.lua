medusa_gaze = class({})
LinkLuaModifier("modifier_medusa_gaze", "heroes/hero_medusa/medusa_gaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_medusa_gaze_slow", "heroes/hero_medusa/medusa_gaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_medusa_gaze_stun", "heroes/hero_medusa/medusa_gaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_medusa_gaze_stun_lesser", "heroes/hero_medusa/medusa_gaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stunned_generic", "libraries/modifiers/modifier_stunned_generic", LUA_MODIFIER_MOTION_NONE)

function medusa_gaze:IsStealable()
	return true
end

function medusa_gaze:IsHiddenWhenStolen()
	return false
end

function medusa_gaze:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Medusa.StoneGaze.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_medusa_gaze", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_medusa_gaze = class({})

function modifier_medusa_gaze:OnCreated(table)
	if IsServer() then
		local caster = self:GetParent()
		caster:StartGesture(ACT_DOTA_MEDUSA_STONE_GAZE)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.radius = self:GetTalentSpecialValueFor("radius")
		self.length = self:GetTalentSpecialValueFor("length")
		self.duration = self:GetTalentSpecialValueFor("face_duration")

		self:StartIntervalThink(0.5)
	end
end

function modifier_medusa_gaze:OnIntervalThink()
	local caster = self:GetParent()

	local x = 25 ---Adds 25 stacks every 0.5 seconds equals 100 at 2 seconds.

	local enemies = caster:FindEnemyUnitsInCone(caster:GetForwardVector(), caster:GetAbsOrigin(), self.radius, self.length, {})
	for _,enemy in pairs(enemies) do
		for i=1,x do
			if not enemy:HasModifier("modifier_medusa_gaze_stun") then
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_medusa_gaze_slow", {Duration = self.duration}):IncrementStackCount()
			end
		end

		if caster:HasTalent("special_bonus_unique_medusa_gaze_2") then
			local damage = caster:GetMaxMana() * 1/100
			self:GetAbility():DealDamage(caster, enemy, damage * 0.5, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
		end
	end
end

function modifier_medusa_gaze:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		caster:RemoveGesture(ACT_DOTA_MEDUSA_STONE_GAZE)
	end
end

modifier_medusa_gaze_slow = class({})
function modifier_medusa_gaze_slow:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()

		EmitSoundOn("Hero_Medusa.StoneGaze.Target", parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_stone_gaze_facing.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx2, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx2)

		if self:GetStackCount() > 99 then
			if not self:GetParent():TriggerSpellAbsorb(self:GetAbility()) then
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_medusa_gaze_stun", {Duration = self:GetTalentSpecialValueFor("stone_duration")})
			end
			self:Destroy()
		end
		self:StartIntervalThink(0.33)
	end
end

function modifier_medusa_gaze_slow:OnRefresh(table)
	if IsServer() then
		if self:GetStackCount() > 99 then
			if not self:GetParent():TriggerSpellAbsorb(self:GetAbility()) then
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_medusa_gaze_stun", {Duration = self:GetTalentSpecialValueFor("stone_duration")})
			end
			self:Destroy()
		end
	end
end

function modifier_medusa_gaze_slow:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() > 99 then
			if not self:GetParent():TriggerSpellAbsorb(self:GetAbility()) then
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_medusa_gaze_stun", {Duration = self:GetTalentSpecialValueFor("stone_duration")})
			end
			self:Destroy()
		end
	end
end

function modifier_medusa_gaze_slow:GetTexture()
	return "ancient_apparition_cold_feet"
end

function modifier_medusa_gaze_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}
	return funcs
end

function modifier_medusa_gaze_slow:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self:GetStackCount()
end

function modifier_medusa_gaze_slow:GetModifierAttackSpeedBonus()
	return -1 * self:GetStackCount()
end

function modifier_medusa_gaze_slow:GetModifierTurnRate_Percentage()
	return -1 * self:GetStackCount()
end

function modifier_medusa_gaze_slow:IsPurgable()
	return false
end

function modifier_medusa_gaze_slow:IsDebuff()
	return true
end

modifier_medusa_gaze_stun = class({})

function modifier_medusa_gaze_stun:OnCreated(table)
	self.bonusPhys = self:GetTalentSpecialValueFor("bonus_physical")

	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_medusa_gaze_1") then
		self.mr = self:GetTalentSpecialValueFor("mr_reduc")
	end

	if IsServer() then
		local parent = self:GetParent()

		EmitSoundOn("Hero_Medusa.StoneGaze.Stun", parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_medusa_gaze_stun:OnRefresh(table)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_medusa_gaze_1") then
		self.mr = self:GetTalentSpecialValueFor("mr_reduc")
	end

	self.bonusPhys = self:GetTalentSpecialValueFor("bonus_physical")
end

function modifier_medusa_gaze_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_medusa_gaze_stun:GetModifierIncomingPhysicalDamage_Percentage()
	return self.bonusPhys
end

function modifier_medusa_gaze_stun:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_medusa_gaze_stun:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_FROZEN] = true}
	return state
end

function modifier_medusa_gaze_stun:IsPurgable()
	return true
end

function modifier_medusa_gaze_stun:IsDebuff()
	return true
end

function modifier_medusa_gaze_stun:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_medusa_gaze_stun:StatusEffectPriority()
	return 11
end

modifier_medusa_gaze_stun_lesser = class({modifier_stunned_generic})

function modifier_medusa_gaze_stun_lesser:OnCreated(table)
	self.bonusPhys = self:GetTalentSpecialValueFor("bonus_physical")

	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_medusa_gaze_1") then
		self.mr = self:GetTalentSpecialValueFor("mr_reduc")
	end

	if IsServer() then
		local parent = self:GetParent()

		EmitSoundOn("Hero_Medusa.StoneGaze.Stun", parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_medusa_gaze_stun_lesser:OnRefresh(table)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_medusa_gaze_1") then
		self.mr = self:GetTalentSpecialValueFor("mr_reduc")
	end

	self.bonusPhys = self:GetTalentSpecialValueFor("bonus_physical")
end

function modifier_medusa_gaze_stun_lesser:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_medusa_gaze_stun_lesser:GetModifierIncomingPhysicalDamage_Percentage()
	return self.bonusPhys
end

function modifier_medusa_gaze_stun_lesser:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_medusa_gaze_stun_lesser:CheckState()
	local state = {[MODIFIER_STATE_FROZEN] = true}
	return state
end

function modifier_medusa_gaze_stun_lesser:IsPurgable()
	return true
end

function modifier_medusa_gaze_stun_lesser:IsDebuff()
	return true
end

function modifier_medusa_gaze_stun_lesser:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_medusa_gaze_stun_lesser:StatusEffectPriority()
	return 11
end

function modifier_medusa_gaze_stun_lesser:GetTexture()
	return "medusa_stone_gaze"
end