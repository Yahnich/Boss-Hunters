grimstroke_ink = class({})
LinkLuaModifier("modifier_grimstroke_ink_one", "heroes/hero_grimstroke/grimstroke_ink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_ink_debuff", "heroes/hero_grimstroke/grimstroke_ink", LUA_MODIFIER_MOTION_NONE)

function grimstroke_ink:IsStealable()
    return true
end

function grimstroke_ink:IsHiddenWhenStolen()
    return false
end

function grimstroke_ink:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
end

function grimstroke_ink:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_Grimstroke.InkSwell.Cast", target)

	target:AddNewModifier(caster, self, "modifier_grimstroke_ink_one", {Duration = duration})
end

modifier_grimstroke_ink_one = class({})
function modifier_grimstroke_ink_one:OnCreated(table)
	self.bonusMS = self:GetSpecialValueFor("bonus_ms")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		local tick_rate = self:GetSpecialValueFor("tick_rate")

		--self:SetDuration(self:GetSpecialValueFor("duration"), true)

		self.dps = self:GetSpecialValueFor("damage_per_second") * tick_rate
		self.damage = self:GetSpecialValueFor("damage")
		self.radius = self:GetSpecialValueFor("radius")
		self.stun_duration = self:GetSpecialValueFor("stun_duration")

		if caster:HasTalent("special_bonus_unique_grimstroke_ink_1") then
			self.talent = true
		end

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_buff.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 2, Vector(self.radius, 0, 0))
					ParticleManager:SetParticleControlEnt(nfx, 3, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)

		self:StartIntervalThink(tick_rate)
	end
end

function modifier_grimstroke_ink_one:OnRefresh(table)
	self.bonusMS = self:GetSpecialValueFor("bonus_ms")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		--self:SetDuration(self:GetSpecialValueFor("duration"), true)

		self.dps = self:GetSpecialValueFor("damage_per_second") * tick_rate
		self.damage = self:GetSpecialValueFor("damage")
		self.radius = self:GetSpecialValueFor("radius")
		self.stun_duration = self:GetSpecialValueFor("stun_duration")

		if caster:HasTalent("special_bonus_unique_grimstroke_ink_1") then
			self.talent = true
		end
	end
end

function modifier_grimstroke_ink_one:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
	if #enemies > 0 then EmitSoundOn("Hero_Grimstroke.InkSwell.Damage", parent) end
	local endDamage = 0
	for _,enemy in pairs(enemies) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_tick_damage.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		if caster:HasTalent("special_bonus_unique_grimstroke_ink_2") and not enemy:IsParalyzed() then
			enemy:Paralyze(ability, caster, self:GetDuration())
		end

		local damage = ability:DealDamage(caster, enemy, self.dps, {}, 0)
		endDamage = endDamage + damage
	end
	if self.talent and endDamage > 0 then
		parent:HealEvent( endDamage, ability, caster )
	end
end

function modifier_grimstroke_ink_one:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_grimstroke_ink_one:GetModifierMoveSpeedBonus_Percentage()
	return self.bonusMS
end

function modifier_grimstroke_ink_one:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		EmitSoundOn("Hero_Grimstroke.InkSwell.Stun", parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 2, Vector(self.radius, self.radius, self.radius))
					ParticleManager:ReleaseParticleIndex(nfx)

		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				EmitSoundOn("Hero_Grimstroke.InkSwell.Target", enemy)
				ability:Stun(enemy, self.stun_duration, false)					
				ability:DealDamage(caster, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
	end
end

function modifier_grimstroke_ink_one:GetStatusEffectName()
	return "particles/status_fx/status_effect_grimstroke_ink_swell.vpcf"
end

function modifier_grimstroke_ink_one:StatusEffectPriority()
	return 11
end

function modifier_grimstroke_ink_one:IsDebuff()
	return false
end

function modifier_grimstroke_ink_one:IsPurgable()
	return true
end