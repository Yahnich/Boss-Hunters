grimstroke_blood = class({})
LinkLuaModifier("modifier_grimstroke_blood", "heroes/hero_grimstroke/grimstroke_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_blood_thing", "heroes/hero_grimstroke/grimstroke_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_blood_toggle", "heroes/hero_grimstroke/grimstroke_blood", LUA_MODIFIER_MOTION_NONE)

function grimstroke_blood:IsStealable()
    return true
end

function grimstroke_blood:IsHiddenWhenStolen()
    return false
end

function grimstroke_blood:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

function grimstroke_blood:GetIntrinsicModifierName()
	return "modifier_grimstroke_blood"
end

function grimstroke_blood:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE
	end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA
end

function grimstroke_blood:OnToggle()
	local caster = self:GetCaster()

	local modifier = "modifier_grimstroke_blood_toggle"

	if caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
	else
		caster:AddNewModifier(caster, self, modifier, {})
	end

end

function grimstroke_blood:CreateInkSpot(vLocation, bMinion)
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")
	local heal = caster:GetIntellect( false) * self:GetSpecialValueFor("heal_creep")
	if not bMinion then
		heal = caster:GetIntellect( false) * self:GetSpecialValueFor("heal")
	end
	CreateModifierThinker(caster, self, "modifier_grimstroke_blood_thing", {Duration = duration, Heal = heal}, vLocation, caster:GetTeam(), false)
end

modifier_grimstroke_blood = class({})

function modifier_grimstroke_blood:OnCreated(table)
	if IsServer() then
		self.heal = self:GetSpecialValueFor("heal_creep")
	end
end

function modifier_grimstroke_blood:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_grimstroke_blood:OnDeath(params)
	if IsServer() then
		local parent = self:GetParent()
		local unit = params.unit
		if CalculateDistance(unit, parent) <= self:GetSpecialValueFor("radius") then
			if unit:GetTeam() ~= parent:GetTeam() then
				self:GetAbility():CreateInkSpot(unit:GetAbsOrigin(), self.heal)
			end
		end
	end
end

function modifier_grimstroke_blood:IsDebuff()
	return false
end

function modifier_grimstroke_blood:IsPurgable()
	return false
end

function modifier_grimstroke_blood:IsHidden()
	return true
end

modifier_grimstroke_blood_thing = class({})

function modifier_grimstroke_blood_thing:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()

		self.radius = self:GetSpecialValueFor("search_radius")
		self.speed = caster:GetProjectileSpeed()

		self.heal = table.Heal

		local newPoint = GetGroundPosition(point, self:GetParent()) + Vector(0, 0, 150)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_blood_passive.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, newPoint)
		self:AttachEffect(nfx)

		self:StartIntervalThink(0.1)
	end
end

function modifier_grimstroke_blood_thing:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local point = self:GetParent():GetAbsOrigin()

	local newPoint = GetGroundPosition(point, self:GetParent()) + Vector(0, 0, 150)

	local allies = caster:FindFriendlyUnitsInRadius(point, self.radius, {order = FIND_CLOSEST})
	for _,ally in pairs(allies) do
		ally:HealEvent(self.heal, self, caster, false)
		self:Destroy()
		break
	end
end

modifier_grimstroke_blood_toggle = class(toggleModifierBaseClass)

function modifier_grimstroke_blood_toggle:OnCreated(table)
	self.cdr = 25
	if IsServer() then
		self.drain = self:GetParent():GetMaxHealth() * 1/100

		self:StartIntervalThink(1)
	end
end

function modifier_grimstroke_blood_toggle:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.drain, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
end

function modifier_grimstroke_blood_toggle:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE }
end

function modifier_grimstroke_blood_toggle:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_grimstroke_blood_toggle:IsDebuff()
	return false
end