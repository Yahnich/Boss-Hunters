elite_nimble = class({})

function elite_nimble:GetIntrinsicModifierName()
	return "modifier_elite_nimble"
end

function elite_nimble:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier(caster, self, "modifier_elite_nimble_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_elite_nimble = class(relicBaseClass)
LinkLuaModifier("modifier_elite_nimble", "elites/elite_nimble", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_nimble:OnCreated()
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(0.2)
	end
	
	function modifier_elite_nimble:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() or caster:HasActiveAbility() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() then return end
		if #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		
		ability:CastSpell()
	end
end

function modifier_elite_nimble:IsHidden()
	return true
end

modifier_elite_nimble_buff = class({})
LinkLuaModifier("modifier_elite_nimble_buff", "elites/elite_nimble", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_nimble_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_AVOID_DAMAGE}
end

function modifier_elite_nimble_buff:GetModifierAvoidDamage()
	ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	return 1
end

function modifier_elite_nimble_buff:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
end