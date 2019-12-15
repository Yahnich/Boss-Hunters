shadow_shaman_ether_lightning = class({})


function shadow_shaman_ether_lightning:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local start_radius = self:GetTalentSpecialValueFor("start_radius")
	local end_radius = self:GetTalentSpecialValueFor("end_radius")
	local end_distance = self:GetTalentSpecialValueFor("end_distance")
	local zapTargets = self:GetTalentSpecialValueFor("targets")
	local damage = self:GetTalentSpecialValueFor("damage")
	local damage_type = self:GetAbilityDamageType()
	local particleName = "particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf"
	local zappedTargets = {}
	
	EmitSoundOn("Hero_ShadowShaman.EtherShock", hCaster)
	
	local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, hCaster)
	ParticleManager:SetParticleControl(lightningBolt,0,Vector(hCaster:GetAbsOrigin().x,hCaster:GetAbsOrigin().y,hCaster:GetAbsOrigin().z + hCaster:GetBoundingMaxs().z ))	
	ParticleManager:SetParticleControl(lightningBolt,1,Vector(hTarget:GetAbsOrigin().x,hTarget:GetAbsOrigin().y,hTarget:GetAbsOrigin().z + hTarget:GetBoundingMaxs().z ))
	ParticleManager:ReleaseParticleIndex(lightningBolt)
	if not target:TriggerSpellAbsorb( self ) then
		local mainDmg = ApplyDamage({ victim = hTarget, attacker = hCaster, damage = damage, damage_type = damage_type, ability = self})
		if hCaster:HasTalent("special_bonus_unique_shadow_shaman_ether_lightning_1") then -- stun
			self:Stun(hTarget, hCaster:FindTalentValue("special_bonus_unique_shadow_shaman_ether_lightning_1"), false)
		end
		if hCaster:HasTalent("special_bonus_unique_shadow_shaman_ether_lightning_2") then -- spellvamp
			hCaster:HealEvent(mainDmg * hCaster:FindTalentValue("special_bonus_unique_shadow_shaman_ether_lightning_2") / 100, self, hCaster)
		end
		hTarget:EmitSound("Hero_ShadowShaman.EtherShock.Target")
	end
	table.insert(zappedTargets, hTarget)
	
	local cone_units = FindUnitsInCone(hCaster:GetTeamNumber(), CalculateDirection(hTarget, hCaster), hCaster:GetAbsOrigin(), end_radius, start_radius + end_distance + end_radius, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, FIND_CLOSEST, 0, false)
	zapTargets = zapTargets - 1
	for _,unit in pairs(cone_units) do
		if zapTargets > 0 then
			if unit ~= hTarget then
				-- Particle
				local origin = unit:GetAbsOrigin()
				local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, hCaster)
				ParticleManager:SetParticleControl(lightningBolt,0,Vector(hCaster:GetAbsOrigin().x,hCaster:GetAbsOrigin().y,hCaster:GetAbsOrigin().z + hCaster:GetBoundingMaxs().z ))	
				ParticleManager:SetParticleControl(lightningBolt,1,Vector(origin.x,origin.y,origin.z + unit:GetBoundingMaxs().z ))
				ParticleManager:ReleaseParticleIndex(lightningBolt)
				-- Damage
				if not unit:TriggerSpellAbsorb( self ) then
					local damage = ApplyDamage({ victim = unit, attacker = hCaster, damage = damage, damage_type = damage_type, ability = self})
					hTarget:EmitSound("Hero_ShadowShaman.EtherShock.Target")
					if hCaster:HasTalent("special_bonus_unique_shadow_shaman_ether_lightning_1") then -- stun
						self:Stun(unit, hCaster:FindTalentValue("special_bonus_unique_shadow_shaman_ether_lightning_1"), false)
					end
					if hCaster:HasTalent("special_bonus_unique_shadow_shaman_ether_lightning_2") then -- spellvamp
						hCaster:HealEvent(damage * hCaster:FindTalentValue("special_bonus_unique_shadow_shaman_ether_lightning_2") / 100, self, hCaster)
					end
				end
				-- Increment counter
				
				zapTargets = zapTargets - 1
				table.insert(zappedTargets, unit)
			end
		else
			break
		end
	end
	if zapTargets > 0 then
		local loops = 0
		newZapped = {}
		Timers:CreateTimer(0.1, function()
			loops = loops + 1
			for _, unit in pairs(zappedTargets) do
				if unit:IsNull() then
					table.remove(zappedTargets, _)
					break 
				end
				table.insert(newZapped, zapTarget)
				if zapTargets == 0 or loops > 10 then return nil end
				local team = hCaster:GetTeamNumber()
				local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
				local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
				local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
				local iOrder = FIND_ANY_ORDER
				local newZapTargets = FindUnitsInRadius(team, unit:GetAbsOrigin(), nil, end_radius, iTeam, iType, iFlag, iOrder, false)
				for _, zapTarget in pairs(newZapTargets) do
					if zapTarget ~= unit then
						local origin = zapTarget:GetAbsOrigin()
						local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, unit)
						ParticleManager:SetParticleControl(lightningBolt,0,Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))	
						ParticleManager:SetParticleControl(lightningBolt,1,Vector(origin.x,origin.y,origin.z + zapTarget:GetBoundingMaxs().z ))
						ParticleManager:ReleaseParticleIndex(lightningBolt)
						-- Damage
						if not unit:TriggerSpellAbsorb( self ) then
							ApplyDamage({ victim = zapTarget, attacker = hCaster, damage = damage, damage_type = damage_type, ability = self})
						end
						hTarget:EmitSound("Hero_ShadowShaman.EtherShock.Target")

						-- Increment counter
						zapTargets = zapTargets - 1
						local inTable = false
						for _, tableUnit in pairs(zappedTargets) do
							if tableUnit == zapTarget then
								inTable = true
							end
						end
						if not inTable then table.insert(newZapped, zapTarget) end
						break -- only hit one new target per unit
					end
				end
			end
			zappedTargets = newZapped
			return 0.1
		end)
		
	end
end
