elite_blinking = class({}) 

function elite_blinking:GetIntrinsicModifierName()
	return "modifier_elite_blinking"
end

function elite_blinking:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()  
	
	local max_distance = self:GetSpecialValueFor("blink_range")
	local min_distance = self:GetSpecialValueFor("min_blink_range")
	caster:Blink( caster:GetAbsOrigin() + CalculateDirection( position, caster ) * math.min(max_distance, math.max(min_distance, CalculateDistance(caster, position) ) ) )
end

modifier_elite_blinking = class(relicBaseClass)
LinkLuaModifier("modifier_elite_blinking", "elites/elite_blinking", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_blinking:OnCreated()
		self:StartIntervalThink( 1 )
	end

	function modifier_elite_blinking:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or caster:IsStunned() or caster:IsSilenced() or caster:GetCurrentActiveAbility() or caster:IsHexed() or caster:IsRooted() then return end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1) ) do
			ability:CastSpell( enemy:GetAbsOrigin() )
			break
		end
	end
end

function modifier_elite_blinking:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_blinking:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end