chen_angel_persuasion = class({})
function chen_angel_persuasion:IsStealable()
	return false
end

function chen_angel_persuasion:IsHiddenWhenStolen()
	return false
end

function chen_angel_persuasion:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Chen.HolyPersuasionCast", caster)

	self:SummonAngel("npc_chen_creature_1", self:GetSpecialValueFor("tank_health"), self:GetSpecialValueFor("tank_damage"))
	self:SummonAngel("npc_chen_creature_2", self:GetSpecialValueFor("dps_health"), self:GetSpecialValueFor("dps_damage"))
	self:SummonAngel("npc_chen_creature_3", self:GetSpecialValueFor("support_health"), self:GetSpecialValueFor("support_damage"))
end

function chen_angel_persuasion:SummonAngel(name, health, damage)
	local caster = self:GetCaster()
	local point = self:GetCursorPosition() + ActualRandomVector(300, 50)

	local duration = self:GetSpecialValueFor("duration")

	if caster:HasScepter() then
		duration = self:GetSpecialValueFor("scepter_duration")
	end

	local angel1 = caster:CreateSummon(name, point, duration)
	EmitSoundOn("sounds/weapons/hero/chen/holy_persuasion_convert.vsnd", angel1)

	ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_holy_persuasion_a.vpcf", PATTACH_POINT, angel1, {})
	FindClearSpaceForUnit(angel1, point, true)
	local maxHP = caster:GetMaxHealth() * health / 100
	angel1:SetBaseMaxHealth(maxHP)
	angel1:SetMaxHealth(health)
	angel1:SetHealth(health)
	local ad = caster:GetAverageTrueAttackDamage(caster) * damage/100
	angel1:SetBaseDamageMax(ad)
	angel1:SetBaseDamageMin(ad)
	angel1:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorValue(false))
	angel1:SetBaseAttackTime(caster:GetBaseAttackTime())

	return angel1
end