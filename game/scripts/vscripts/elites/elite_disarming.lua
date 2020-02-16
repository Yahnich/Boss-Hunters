elite_disarming = class({})

function elite_disarming:GetIntrinsicModifierName()
	return "modifier_elite_disarming"
end

function elite_disarming:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier(caster, self, "modifier_elite_disarming_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_elite_disarming = class(relicBaseClass)
LinkLuaModifier("modifier_elite_disarming", "elites/elite_disarming", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_disarming:OnCreated()
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(0.2)
	end
	
	function modifier_elite_disarming:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() or caster:HasActiveAbility() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() then return end
		if #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		
		ability:CastSpell()
	end
end

function modifier_elite_disarming:IsHidden()
	return true
end

modifier_elite_disarming_buff = class({})
LinkLuaModifier("modifier_elite_disarming_buff", "elites/elite_disarming", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_disarming_buff:OnCreated()
		self.duration = self:GetSpecialValueFor("disarm_duration")
	end
	
	function modifier_elite_disarming_buff:OnDestroy()
		self.duration = self:GetSpecialValueFor("disarm_duration")
	end
end

function modifier_item_protection_sphere_block:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_protection_sphere_block:OnAttackLanded(params)
	if params.target == self:GetParent() then
		params.attacker:Disarm(self:GetAbility(), params.target, self.duration)
	end
end

function modifier_elite_disarming_buff:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"
end