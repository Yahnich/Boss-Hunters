boss12a_split = class({})

function boss12a_split:GetIntrinsicModifierName()
	return	"modifier_boss12a_split_passive"
end

modifier_boss12a_split_passive = class({})
LinkLuaModifier("modifier_boss12a_split_passive", "bosses/boss12/boss12a_split.lua", 0)

function modifier_boss12a_split_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss12a_split_passive:OnDeath(params)
	if params.unit == self:GetParent() then
		for i = 1, self:GetSpecialValueFor("spawn_count") do self:CreateGolem() end
	end
end


function modifier_boss12a_split_passive:CreateGolem()
	local golem = CreateUnitByName("npc_dota_boss12_b", self:GetCaster():GetAbsOrigin() + ActualRandomVector(400, 200), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam())
	ParticleManager:FireParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_ground_rocks.vpcf", PATTACH_POINT_FOLLOW, golem)
end