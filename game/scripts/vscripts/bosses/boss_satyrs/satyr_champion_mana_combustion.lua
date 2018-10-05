satyr_champion_mana_combustion = class({})

function satyr_champion_mana_combustion:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	return true
end

function satyr_champion_mana_combustion:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local burn = self:GetSpecialValueFor("mana_burn")
	local damage = self:GetSpecialValueFor("burn_damage") / 100
	local delay = self:GetSpecialValueFor("delay")
	
	local warmUp = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp_charge.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( warmUp, 0, position )
	
	caster:EmitSound("Hero_Invoker.EMP.Charge")
	
	Timers:CreateTimer(delay, function()
			if caster:IsNull() then return end
			ParticleManager:ClearParticle( warmUp )
			caster:StopSound("Hero_Invoker.EMP.Charge")
			EmitSoundOnLocationWithCaster(position, "Hero_Invoker.EMP.Discharge", caster)
			ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_emp_explode.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,radius,radius)})
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
				if not enemy:TriggerSpellAbsorb(self) then
					enemy:ReduceMana( burn )
					self:DealDamage( caster, enemy, burn * damage )
				end
			end
		end
	)
end