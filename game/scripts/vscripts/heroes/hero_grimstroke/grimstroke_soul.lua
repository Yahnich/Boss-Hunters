grimstroke_soul = class({})
LinkLuaModifier("modifier_grimstroke_soul_one", "heroes/hero_grimstroke/grimstroke_soul", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_soul_debuff", "heroes/hero_grimstroke/grimstroke_soul", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_soul_slow", "heroes/hero_grimstroke/grimstroke_soul", LUA_MODIFIER_MOTION_NONE)

function grimstroke_soul:IsStealable()
    return true
end

function grimstroke_soul:IsHiddenWhenStolen()
    return false
end

function grimstroke_soul:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_Grimstroke.SoulChain.Cast", caster)
	EmitSoundOn("Hero_Grimstroke.SoulChain.Target", target)
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,enemy in pairs(enemies) do
		enemy:RemoveModifierByName("modifier_grimstroke_soul_one")
		enemy:RemoveModifierByName("modifier_grimstroke_soul_debuff")
	end
	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(caster, self, "modifier_grimstroke_soul_one", {Duration = duration})
end

modifier_grimstroke_soul_one = class({})
function modifier_grimstroke_soul_one:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		self.radius = self:GetSpecialValueFor("radius")
		self.breakdistance = self:GetSpecialValueFor("break_distance")

		self.nfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_soulchain.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(self.nfx1, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(self.nfx1, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AttachEffect(self.nfx1)

		if caster:HasTalent("special_bonus_unique_grimstroke_soul_1") then
			parent:Daze(self:GetAbility(), caster, self:GetDuration())
		end
		
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius, {order = FIND_CLOSEST})
		for _,enemy in pairs(enemies) do
			if enemy ~= parent then
				EmitSoundOn("Hero_Grimstroke.SoulChain.Partner", enemy)

				self.target = enemy

				ParticleManager:SetParticleControlEnt(self.nfx1, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)

				self.target:AddNewModifier(caster, self:GetAbility(), "modifier_grimstroke_soul_debuff", {Duration = self:GetDuration()})
				
				if caster:HasTalent("special_bonus_unique_grimstroke_soul_1") then
					self.target:Daze(self:GetAbility(), caster, self:GetDuration())
				end

				break
			end
		end

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)

		self:StartIntervalThink(0.07)
	end
end

function modifier_grimstroke_soul_one:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()

	if not self.target or self.target:IsNull() or not self.target:IsAlive() then
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius, {order = FIND_CLOSEST})
		for _,enemy in pairs(enemies) do
			if enemy ~= parent then
				EmitSoundOn("Hero_Grimstroke.SoulChain.Partner", enemy)
				
				self.target = enemy
				
				ParticleManager:SetParticleControlEnt(self.nfx1, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
				
				self.target:AddNewModifier(caster, self:GetAbility(), "modifier_grimstroke_soul_debuff", {Duration = self:GetRemainingTime()})
				
				if caster:HasTalent("special_bonus_unique_grimstroke_soul_1") then
					self.target:Daze(self:GetAbility(), caster, self:GetRemainingTime())
					parent:Daze(self:GetAbility(), caster, self:GetRemainingTime())
				end

				break
			end
		end
	else
		if CalculateDistance(self.target, parent) > self.breakdistance then
			self.target:RemoveModifierByName("modifier_grimstroke_soul_debuff")
			self.target:RemoveModifierByName("modifier_grimstroke_soul_slow")
			parent:RemoveModifierByName("modifier_grimstroke_soul_slow")
			ParticleManager:SetParticleControlEnt(self.nfx1, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			self.target = false

		else
			local futurePointTarget = self.target:GetAbsOrigin() + self.target:GetForwardVector() * 50
			local futurePointParent = parent:GetAbsOrigin() + parent:GetForwardVector() * 50
			if CalculateDistance(futurePointTarget, futurePointParent) > self.radius then
				self.target:AddNewModifier(caster, self:GetAbility(), "modifier_grimstroke_soul_slow", {Duration = self.duration})
				parent:AddNewModifier(caster, self:GetAbility(), "modifier_grimstroke_soul_slow", {Duration = self.duration})
			else
				self.target:RemoveModifierByName("modifier_grimstroke_soul_slow")
				parent:RemoveModifierByName("modifier_grimstroke_soul_slow")
			end
		end
	end
end

function modifier_grimstroke_soul_one:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_grimstroke_soul_one:OnTakeDamage(params)
	if IsServer() then
		if self.target then
			local caster = self:GetCaster()
			local parent = self:GetParent()
			local attacker = params.attacker
			local original_damage = params.original_damage
			local damage_type = params.damage_type
			local damage_flags = params.damage_flags
			local unit = params.unit

			if parent == unit then
				self:GetAbility():DealDamage(attacker, self.target, original_damage, {damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, OVERHEAD_ALERT_DAMAGE)
			elseif self.target == unit then
				self:GetAbility():DealDamage(attacker, parent, original_damage, {damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, OVERHEAD_ALERT_DAMAGE)
			end
		end
	end
end

function modifier_grimstroke_soul_one:OnRemoved()
	if IsServer() then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
		for _,enemy in pairs(enemies) do
			enemy:RemoveModifierByName("modifier_grimstroke_soul_slow")
			enemy:RemoveModifierByName("modifier_grimstroke_soul_debuff")
		end
		if self:GetRemainingTime() > 0 then
			for _,enemy in pairs(enemies) do
				if self:GetRemainingTime() > 0 then
					EmitSoundOn("Hero_Grimstroke.SoulChain.Partner", enemy)
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_grimstroke_soul_one", {Duration = self:GetRemainingTime()})
					break
				end
			end
		end
		if self:GetCaster():HasTalent("special_bonus_unique_grimstroke_soul_2") then
			local percent = 5
			local damage = self:GetParent():GetMaxHealth() * percent/100
			self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end

function modifier_grimstroke_soul_one:IsDebuff()
	return true
end

function modifier_grimstroke_soul_one:IsPurgable()
	return false
end

modifier_grimstroke_soul_debuff = class({})
function modifier_grimstroke_soul_debuff:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)
	end
end

function modifier_grimstroke_soul_debuff:OnRemoved()
	if IsServer() then
		if self:GetCaster():HasTalent("special_bonus_unique_grimstroke_soul_2") then
			local percent = 5
			local damage = self:GetParent():GetMaxHealth() * percent/100
			self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end

function modifier_grimstroke_soul_debuff:IsDebuff()
	return true
end

function modifier_grimstroke_soul_debuff:IsPurgable()
	return false
end

modifier_grimstroke_soul_slow = class({})
function modifier_grimstroke_soul_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
			MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_MAX}
end

function modifier_grimstroke_soul_slow:GetModifierMoveSpeedBonus_Percentage()
	return -500
end

function modifier_grimstroke_soul_slow:GetModifierMoveSpeed_Absolute()
	return -1
end

function modifier_grimstroke_soul_slow:GetModifierMoveSpeed_AbsoluteMin()
	return -1
end

function modifier_grimstroke_soul_slow:GetModifierMoveSpeed_Limit()
	return -1
end

function modifier_grimstroke_soul_slow:GetModifierMoveSpeed_Max()
	return -1
end

function modifier_grimstroke_soul_slow:IsHidden()
	return true
end

function modifier_grimstroke_soul_slow:IsPurgable()
	return false
end