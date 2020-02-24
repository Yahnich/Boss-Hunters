elite_frenzied = class({})

function elite_frenzied:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier( caster, self, "modifier_elite_frenzied_buff", {duration = self:GetSpecialValueFor("duration")})
end

function elite_frenzied:GetIntrinsicModifierName()
	return "modifier_elite_frenzied"
end

modifier_elite_frenzied = class(relicBaseClass)
LinkLuaModifier("modifier_elite_frenzied", "elites/elite_frenzied", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_elite_frenzied:OnCreated()
		self:StartIntervalThink(1)
	end
	
	function modifier_elite_frenzied:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not caster:IsAttacking() or not ability:IsFullyCastable() or caster:PassivesDisabled() then return end
		ability:CastSpell()
	end
end

function modifier_elite_frenzied:GetEffectName()
	return "particles/units/elite_warning_offense_overhead.vpcf"
end

function modifier_elite_frenzied:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_frenzied_buff = class({})
LinkLuaModifier("modifier_elite_frenzied_buff", "elites/elite_frenzied", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_frenzied_buff:OnCreated()
	self.as = self:GetSpecialValueFor("attackspeed")
	self.ms = self:GetSpecialValueFor("movespeed")
end

function modifier_elite_frenzied_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
end

function modifier_elite_frenzied_buff:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_elite_frenzied_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_elite_frenzied_buff:GetEffectName()
	return	"particles/items2_fx/mask_of_madness.vpcf"
end