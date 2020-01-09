necrophos_reapers_scythe_bh = class({})

function necrophos_reapers_scythe_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function necrophos_reapers_scythe_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast.ti7", caster)
	local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(sFX, 1, position)
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("delay")
	local damage = caster:GetHealth() * self:GetTalentSpecialValueFor("curr_hp_damage") / 100
	
	local talent1 = caster:HasTalent("special_bonus_unique_necrophos_reapers_scythe_1")
	local maxHPDamage = caster:FindTalentValue("special_bonus_unique_necrophos_reapers_scythe_1") / 100
	local enemies = caster:FindEnemyUnitsInRadius( position, radius )
	local spellBlockEnemies = {}
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb(self) then
			local modifier = self:Stun(enemy, duration)
			if modifier then
				local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf", PATTACH_POINT_FOLLOW, enemy)
				modifier:AddEffect(nFX)
			end
		else
			spellBlockEnemies[enemy] = true
		end
	end
	
	Timers:CreateTimer(duration, function()
		local damageDealt = 0
		for _, enemy in ipairs( enemies ) do
			if not spellBlockEnemies[enemy] then
				local appliedDamage = damage
				if talent1 then
					appliedDamage = appliedDamage + enemy:GetMaxHealth() * maxHPDamage
				end
				damageDealt = self:DealDamage( caster, enemy, appliedDamage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
			end
		end
		if caster:HasTalent("special_bonus_unique_necrophos_reapers_scythe_2") then
			local heal = damageDealt * caster:FindTalentValue("special_bonus_unique_necrophos_reapers_scythe_2") / 100
			local allies = caster:FindFriendlyUnitsInRadius( position, radius )
			-- ensure caster is in the list, but doesn't appear twice
			for id, ally in ipairs( allies ) do
				if ally == caster then
					table.remove( allies, id )
					break
				end
			end
			table.insert( allies, caster )
			
			heal = heal / #allies
			for _, ally in ipairs( allies ) do
				ally:HealEvent( heal, self, caster )
			end
		end
	end)
end

