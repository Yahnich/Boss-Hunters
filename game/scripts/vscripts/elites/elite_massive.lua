elite_massive = class({})

function elite_massive:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_elite_massive_buff", {duration = self:GetSpecialValueFor("duration")})
end

function elite_massive:GetIntrinsicModifierName()
	return "modifier_elite_massive"
end

modifier_elite_massive = class(relicBaseClass)
LinkLuaModifier("modifier_elite_massive", "elites/elite_massive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_massive:OnCreated()
		self:StartIntervalThink(1)
	end
	
	function modifier_elite_massive:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster:PassivesDisabled() or not ability:IsFullyCastable() then return end
		ability:CastSpell()
	end
end