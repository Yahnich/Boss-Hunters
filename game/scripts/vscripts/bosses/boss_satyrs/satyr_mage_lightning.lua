satyr_mage_lightning = class({})

function satyr_mage_lightning:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("n_creep_HarpyStorm.Shoot")
	return true
end

function satyr_mage_lightning:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local prevTarget = caster
	local damage = self:GetSpecialValueFor("damage")
	local bounces = self:GetSpecialValueFor("bounces")
	local radius = self:GetSpecialValueFor("search_radius")
	
	local hitUnits = {}
	Timers:CreateTimer(function()
		if target and caster and not caster:IsNull() then
			if target:TriggerSpellAbsorb(self) then return end
			target:EmitSound("n_creep_HarpyStorm.ChainLighting")
			self:DealDamage( caster, target, damage )
			ParticleManager:FireRopeParticle("particles/neutral_fx/harpy_chain_lightning.vpcf", PATTACH_POINT_FOLLOW, prevTarget, target)
			prevTarget = target
			hitUnits[target:entindex()] = true
			target = nil
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( prevTarget:GetAbsOrigin(), radius ) ) do
				if not hitUnits[enemy:entindex()] then
					target = enemy
					break
				end
			end
			if bounces > 0 then
				bounces = bounces - 1
				return 0.35
			end
		end
	end)
end
