boss26_rend = class({})

function boss26_rend:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	local distance =  self:GetCastRange(caster:GetAbsOrigin(), caster)
	local position = caster:GetAbsOrigin() + direction * distance
	ParticleManager:FireWarningParticle(position, distance)
	return true
end



function boss26_rend:OnSpellStart()
	local caster = self:GetCaster()
	local distance =  self:GetCastRange(caster:GetAbsOrigin(), caster)
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	local position = caster:GetAbsOrigin() + direction * distance
	
	local damagePerStack = self:GetSpecialValueFor("bonus_damage_per_stack")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Ursa.Overpower", caster)
	
	ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_fury_sweep_up_right.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] =  caster:GetAnglesAsVector()})
	local enemies = caster:FindEnemyUnitsInRadius(position, distance)
	for _, enemy in ipairs(enemies) do
		local stacks = 0
		if enemy:HasModifier("modifier_boss26_rend_stack") then stacks = enemy:FindModifierByName("modifier_boss26_rend_stack"):GetStackCount() end
		self:DealDamage(caster, enemy, damage + stacks * damagePerStack)
		enemy:AddNewModifier(caster, self, "modifier_boss26_rend_stack", {duration = duration})
		ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf", PATTACH_POINT_FOLLOW, caster)
		
	end
	EmitSoundOn("Hero_Ursa.Attack", caster)
end


modifier_boss26_rend_stack = class({})
LinkLuaModifier("modifier_boss26_rend_stack", "bosses/boss27/boss26_rend.lua", 0)

if IsServer() then
	function modifier_boss26_rend_stack:OnCreated()
		self:SetStackCount(1)
	end

	function modifier_boss26_rend_stack:OnRefresh()
		self:IncrementStackCount()
	end
end

function modifier_boss26_rend_stack:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_boss26_rend_stack:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end