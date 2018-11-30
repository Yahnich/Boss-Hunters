boss18b_swipe = class({})

function boss18b_swipe:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	local distance =  self:GetCastRange(caster:GetAbsOrigin(), caster)
	local position = caster:GetAbsOrigin() + direction * distance
	ParticleManager:FireWarningParticle(position, distance/2)
	if caster:GetHealthPercent() < 66 then
		for i = 1, 2 do
			local newDir = RotateVector2D(direction, ToRadians(45) * (-1)^i )
			local position = caster:GetAbsOrigin() + newDir * distance
			ParticleManager:FireWarningParticle(position, distance/2)
		end
	end
	if caster:GetHealthPercent() < 33 then
		for i = 1, 4 do
			local newDir = RotateVector2D(direction, ToRadians(45) * 2 * (-1)^i )
			local position = caster:GetAbsOrigin() + newDir * distance
			ParticleManager:FireWarningParticle(position, distance/2)
		end
	end
	return true
end

function boss18b_swipe:OnSpellStart()
	local caster = self:GetCaster()
	local distance =  self:GetCastRange(caster:GetAbsOrigin(), caster)
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	local position = caster:GetAbsOrigin() + direction * distance
	
	ParticleManager:FireParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] =  caster:GetAnglesAsVector()})
	local enemies = caster:FindEnemyUnitsInRadius(position, distance/2)
	for _, enemy in ipairs(enemies) do
		caster:PerformGenericAttack(enemy, true)
		enemy:AddNewModifier(caster, self, "modifier_boss18b_swipe_bleed", {duration = self:GetSpecialValueFor("duration")})
	end
	
	if caster:GetHealthPercent() < 66 then
		for i = 1, 2 do
			local newDir = RotateVector2D(direction, ToRadians(45) * (-1)^i )
			local newPos = caster:GetAbsOrigin() + newDir * distance
			ParticleManager:FireParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = newPos, [1] =  caster:GetAnglesAsVector()})
			local enemies = caster:FindEnemyUnitsInRadius(newPos, distance/2)
			for _, enemy in ipairs(enemies) do
				if not enemy:TriggerSpellAbsorb(self) then
					caster:PerformGenericAttack(enemy, true)
					enemy:AddNewModifier(caster, self, "modifier_boss18b_swipe_bleed", {duration = self:GetSpecialValueFor("duration")})
				end
			end
		end
	end
	if caster:GetHealthPercent() < 33 then
		for i = 1, 4 do
			local newDir = RotateVector2D(direction, ToRadians(45) * 2 * (-1)^i )
			local newPos = caster:GetAbsOrigin() + newDir * distance
			local newPos = caster:GetAbsOrigin() + newDir * distance
			ParticleManager:FireParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = newPos, [1] =  caster:GetAnglesAsVector()})
			local enemies = caster:FindEnemyUnitsInRadius(newPos, distance/2)
			for _, enemy in ipairs(enemies) do
				if not enemy:TriggerSpellAbsorb(self) then
					caster:PerformGenericAttack(enemy, true)
					enemy:AddNewModifier(caster, self, "modifier_boss18b_swipe_bleed", {duration = self:GetSpecialValueFor("duration")})
				end
			end
		end
	end
	EmitSoundOn("hero_bloodseeker.rupture.cast", caster)
end


modifier_boss18b_swipe_bleed = class({})
LinkLuaModifier("modifier_boss18b_swipe_bleed", "bosses/boss18b/boss18b_swipe.lua", 0)


function modifier_boss18b_swipe_bleed:OnCreated()
	self.moveslow = self:GetSpecialValueFor("moveslow")
	self.attackslow = self:GetSpecialValueFor("attackslow")
end


function modifier_boss18b_swipe_bleed:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, }
end

function modifier_boss18b_swipe_bleed:GetModifierMoveSpeedBonus_Constant()
	return self.moveslow
end

function modifier_boss18b_swipe_bleed:GetModifierAttackSpeedBonus()
	return self.attackslow
end

function modifier_boss18b_swipe_bleed:GetDisableHealing()
	return 1
end

function modifier_boss18b_swipe_bleed:GetEffectName()
	return "particles/bosses/boss18b/boss18b_swipe_bleed.vpcf"
end