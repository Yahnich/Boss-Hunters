boss19_burrow = class({})

function boss19_burrow:OnAbilityPhaseStart(bConsecutive)
	if not bConsecutive then self.recast_count = self:GetSpecialValueFor("frenzy_stuns")
	else self.recast_count = (self.recast_count or self:GetSpecialValueFor("frenzy_stuns")) - 1 end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("stun_radius"))
	EmitSoundOn("Hero_NyxAssassin.Burrow.In", self:GetCaster())
	return true
end

function boss19_burrow:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local stunRadius = self:GetSpecialValueFor("stun_radius")
	local damage = self:GetSpecialValueFor("stun_damage")
	
	FindClearSpaceForUnit(caster, position, true)
	local enemies = caster:FindEnemyUnitsInRadius(position, stunRadius)
	for _, enemy in ipairs(enemies) do
		self:DealDamage(caster, enemy, damage)
	end
	
	caster:StartGesture(ACT_DOTA_CAST_BURROW_END)
	EmitSoundOn("Hero_Leshrac.Split_Earth", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(stunRadius, stunRadius, stunRadius)})
	
	if caster:GetHealthPercent() < 75 then
		local chasm = caster:FindAbilityByName("boss19_chasm")
		local impaleTargets = caster:FindEnemyUnitsInRadius(position, chasm:GetSpecialValueFor("proj_distance"))
		for _, target in ipairs(impaleTargets) do
			caster:SetCursorPosition(target:GetAbsOrigin())
			chasm:OnSpellStart()
		end
	end
	
	if self.recast_count > 0 and caster:GetHealthPercent() < 40 then
		local newPos = position + ActualRandomVector(1000, 400)
		caster:SetCursorPosition( newPos )
		self:OnAbilityPhaseStart(true)
		Timers:CreateTimer(self:GetCastPoint(), function() self:OnSpellStart() end)
	end
end