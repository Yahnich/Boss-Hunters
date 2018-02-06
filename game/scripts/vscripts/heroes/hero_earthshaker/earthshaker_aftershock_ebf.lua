earthshaker_aftershock_ebf = class({})

function earthshaker_aftershock_ebf:GetIntrinsicModifierName()
	return "modifier_earthshaker_aftershock_ebf_passive"
end

function earthshaker_aftershock_ebf:Aftershock(position, radius)
	local caster = self:GetCaster()
	local vPos = position or caster:GetAbsOrigin()
	
	local damage = self:GetTalentSpecialValueFor("str_damage") / 100 * caster:GetStrength()
	local duration = self:GetTalentSpecialValueFor("max_duration")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(vPos, radius) ) do
		self:DealDamage(caster, enemy, damage)
		self:Stun(enemy, duration, false)
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = vPos, [1] = Vector(radius, radius, radius)})
	EmitSoundOn( "Hero_EarthShaker.EchoSlamSmall", caster)
end

modifier_earthshaker_aftershock_ebf_passive = class({})
LinkLuaModifier("modifier_earthshaker_aftershock_ebf_passive", "heroes/hero_earthshaker/earthshaker_aftershock_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_earthshaker_aftershock_ebf_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_earthshaker_aftershock_ebf_passive:OnAbilityExecuted( params )
	if params.unit == self:GetParent() and self:GetParent():HasAbility( params.ability:GetName() ) then
		local radius = self:GetTalentSpecialValueFor("aftershock_range")
		self:GetAbility():Aftershock(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("aftershock_range"))
	end
end

function modifier_earthshaker_aftershock_ebf_passive:IsHidden()
	return true
end