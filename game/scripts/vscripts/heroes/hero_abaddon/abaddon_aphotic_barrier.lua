abaddon_aphotic_barrier = class({})

function abaddon_aphotic_barrier:IsStealable()
	return true
end

function abaddon_aphotic_barrier:IsHiddenWhenStolen()
	return false
end

function abaddon_aphotic_barrier:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_abaddon_aphotic_barrier_2") then cd = cd + self:GetCaster():FindTalentValue("special_bonus_unique_abaddon_aphotic_barrier_2") end
	return cd
end

function abaddon_aphotic_barrier:GetBehavior(iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_abaddon_aphotic_barrier_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end


function abaddon_aphotic_barrier:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or caster
	target:Dispel(caster, true)
	target:RemoveModifierByName("modifier_abaddon_aphotic_barrier")
	if caster:HasTalent("special_bonus_unique_abaddon_aphotic_barrier_1") then
		local targets = caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_abaddon_aphotic_barrier_1") )
		for _, hitTarget in ipairs( targets ) do
			hitTarget:AddNewModifier(caster, self, "modifier_abaddon_aphotic_barrier", {duration = self:GetTalentSpecialValueFor("duration")})
		end
	else
		target:AddNewModifier(caster, self, "modifier_abaddon_aphotic_barrier", {duration = self:GetTalentSpecialValueFor("duration")})
	end
end


modifier_abaddon_aphotic_barrier = class({})
LinkLuaModifier("modifier_abaddon_aphotic_barrier", "heroes/hero_abaddon/abaddon_aphotic_barrier", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_aphotic_barrier:OnCreated()
	self.absorb = self:GetTalentSpecialValueFor("damage_absorb")
	if IsServer() then
		local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		local sRadius = self:GetParent():GetModelRadius() * 0.6 + 25
		local vFX = Vector(sRadius,0,sRadius)
		ParticleManager:SetParticleControlEnt(nFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nFX, 1, vFX)
		ParticleManager:SetParticleControl(nFX, 2, vFX)
		ParticleManager:SetParticleControl(nFX, 4, vFX)
		ParticleManager:SetParticleControl(nFX, 5, vFX)
		self:AddEffect(nFX)
	end
end

function modifier_abaddon_aphotic_barrier:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		EmitSoundOn("Hero_Abaddon.AphoticShield.Destroy", parent)
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
		local damage =  self:GetTalentSpecialValueFor("damage_absorb")
		for _, enemy in ipairs( enemies ) do
			self:GetAbility():DealDamage(caster, enemy, damage)
		end
	end
end

function modifier_abaddon_aphotic_barrier:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_abaddon_aphotic_barrier:GetModifierIncomingDamage_Percentage(params)
	if not self:GetParent():HasModifier("modifier_abaddon_borrowed_time_active") then
		if self.absorb > params.damage then
			self.absorb = self.absorb - params.damage
			return -999
		else
			self:Destroy()
			return ((self.absorb / params.damage) * 100) * (-1)
		end
	end
end

function modifier_abaddon_aphotic_barrier:OnTooltip()
	return self.absorb
end