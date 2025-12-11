chen_dps_strike = class({})
function chen_dps_strike:IsStealable()
	return true
end

function chen_dps_strike:IsHiddenWhenStolen()
	return false
end

function chen_dps_strike:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function chen_dps_strike:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local damage = 0
	local radius = self:GetTalentSpecialValueFor("radius")

	EmitSoundOn("Hero_Invoker.SunStrike.Charge.Apex", caster)

	ParticleManager:FireParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_team_immortal1.vpcf", PATTACH_WORLDORIGIN, nil, {[0]=point,[1]=Vector(radius,1,1)})

	Timers:CreateTimer(1.5, function()
		EmitSoundOnLocationWithCaster(point, "Hero_Invoker.SunStrike.Ignite.Apex", caster)

		ParticleManager:FireParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf", PATTACH_WORLDORIGIN, nil, {[0]=point,[1]=Vector(radius,1,1)})

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			if caster:GetOwner() then
				damage = caster:GetOwner():GetIntellect( false)*self:GetTalentSpecialValueFor("damage")/100
			else
				damage = caster:GetIntellect( false)*self:GetTalentSpecialValueFor("damage")/100
			end

			self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_DAMAGE)
			self:Stun(enemy, self:GetTalentSpecialValueFor("duration"), false)
		end
	end)
end