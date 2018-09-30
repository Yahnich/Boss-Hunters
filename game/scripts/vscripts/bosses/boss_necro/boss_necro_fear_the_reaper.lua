boss_necro_fear_the_reaper = class({})

function boss_necro_fear_the_reaper:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Necrolyte.ReapersScythe.Caster", self:GetCaster() )
	return true
end

function boss_necro_fear_the_reaper:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	self:CreateReaper(target)
	
	Timers:CreateTimer(RandomFloat(0.75, 1.5), function()
		if caster:GetHealthPercent() <= 50 then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
				if not enemy:TriggerSpellAbsorb(self) then
					self:CreateReaper( enemy:GetAbsOrigin() )
				end
				break
			end
		end
	end)
end

function boss_necro_fear_the_reaper:CreateReaper(target)
	local caster = self:GetCaster()
	ParticleManager:FireWarningParticle(target, self:GetSpecialValueFor("radius"))
	
	local sFX = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necro_sullen_harvest/necro_sullen_harvest_scythe_model.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(sFX, 1, target)
	
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")
	Timers:CreateTimer(1.5, function()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target, radius ) ) do
			if not enemy:TriggerSpellAbsorb(self) then
				self:DealDamage(caster, enemy, damage )
			end
		end
	end)
end