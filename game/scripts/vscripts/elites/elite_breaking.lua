elite_breaking = class({})

function elite_breaking:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:ModifyThreat(25)
	target:AddNewModifier(caster, self, "modifier_elite_breaking_debuff", {duration = self:GetSpecialValueFor("duration")})
end

function elite_breaking:GetIntrinsicModifierName()
	return "modifier_elite_breaking"
end

modifier_elite_breaking = class(relicBaseClass)
LinkLuaModifier("modifier_elite_breaking", "elites/elite_breaking", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_elite_breaking:OnCreated()
		self:StartIntervalThink( 1 )
	end

	function modifier_elite_breaking:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or caster:GetCurrentActiveAbility() then return end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 900 ) ) do
			ability:CastSpell( enemy )
			break
		end
	end
end

modifier_elite_breaking_debuff = class({})
LinkLuaModifier("modifier_elite_breaking_debuff", "elites/elite_breaking", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_breaking_debuff:OnCreated()
	self.armor = self:GetSpecialValueFor("minus_armor_per_raid")
	if IsServer() then
		self:SetStackCount( 1 + RoundManager:GetRaidsFinished() )
	end
end

function modifier_elite_breaking_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_elite_breaking_debuff:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end

function modifier_elite_breaking_debuff:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
end

function modifier_elite_breaking_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end