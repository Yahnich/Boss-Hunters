elite_fortified = class({})

function elite_fortified:OnSpellStart()
	local caster = self:GetCaster()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_POINT_FOLLOW, caster)
	caster:AddNewModifier(caster, self, "modifier_elite_fortified_buff", {duration = self:GetSpecialValueFor("duration")})
end

function elite_fortified:GetIntrinsicModifierName()
	return "modifier_elite_fortified"
end

modifier_elite_fortified = class(relicBaseClass)
LinkLuaModifier("modifier_elite_fortified", "elites/elite_fortified", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_elite_fortified:OnCreated()
		self.hp = self:GetParent():GetHealthPercent()
		self:StartIntervalThink( 1 )
	end

	function modifier_elite_fortified:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or caster:GetCurrentActiveAbility() then return end
		if self.hp > self:GetParent():GetHealthPercent() then
			ability:CastSpell()
			self.hp = self:GetParent():GetHealthPercent()
		end
	end
end

function modifier_elite_fortified:GetEffectName()
	return "particles/units/elite_warning_defense_overhead.vpcf"
end

function modifier_elite_fortified:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_fortified_buff = class({})
LinkLuaModifier("modifier_elite_fortified_buff", "elites/elite_fortified", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_fortified_buff:OnCreated()
	self.reduction = self:GetSpecialValueFor("dmg_reduction")
	self.slow = self:GetSpecialValueFor("move_slow")
end

function modifier_elite_fortified_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_elite_fortified_buff:GetModifierIncomingDamage_Percentage()
	return self.reduction
end

function modifier_elite_fortified_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_elite_fortified_buff:GetEffectName()
	return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end