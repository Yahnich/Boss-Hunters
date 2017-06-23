shinigami_whirling_slash = class({})

function shinigami_whirling_slash:GetCastRange(entity, position)
	return self:GetCaster():GetAttackRange()+150
end

function shinigami_whirling_slash:OnSpellStart()
	local caster = self:GetCaster()
	local angles = caster:GetAnglesAsVector()
	local angleSet = - 90
	local maxRotation = self:GetTalentSpecialValueFor("rotation_degree")
	local angVel = maxRotation / self:GetTalentSpecialValueFor("duration") * FrameTime()
	
	local reduction = 1 - self:GetSpecialValueFor("damage_reduction") / 100
	local bonusDamage = caster:GetAverageTrueAttackDamage(caster)
	
	EmitSoundOn("Hero_SkeletonKing.CriticalStrike", caster)
	caster:SetAngles(angles.x , angles.y + angleSet, angles.z)
	local modifier = caster:AddNewModifier(caster, self, "modifier_shinigami_whirling_slash_stop_movement", {})
	modifier:SetStackCount(bonusDamage)
	local attackblur = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_whirling_slash.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(attackblur, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(attackblur)
	local alreadyAttacked = {}
	Timers:CreateTimer(0, function()
		local enemiesInLine = FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:GetAbsOrigin()+caster:GetForwardVector()*(caster:GetAttackRange()+150), nil, 125, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
		for _, enemy in ipairs(enemiesInLine) do
			if not alreadyAttacked[enemy:entindex()] then
				caster:PerformAttack(enemy,true,true,true,false,false,false,true)
				EmitSoundOn("Hero_Shredder.Attack.Post", enemy)
				modifier:SetStackCount(bonusDamage*reduction)
				alreadyAttacked[enemy:entindex()] = true
			end
		end
		if angleSet < maxRotation - 90 then
			caster:SetAngles(angles.x , angles.y + angleSet, angles.z)
			angleSet = angleSet + angVel
			return FrameTime()
		else
			caster:SetAngles(angles.x , angles.y + angleSet, angles.z)
			caster:RemoveModifierByName("modifier_shinigami_whirling_slash_stop_movement")
		end
	end)
end



modifier_shinigami_whirling_slash_stop_movement = class({})
LinkLuaModifier("modifier_shinigami_whirling_slash_stop_movement", "heroes/shinigami/shinigami_whirling_slash.lua", 0)

function modifier_shinigami_whirling_slash_stop_movement:IsHidden()
	return true
end

function modifier_shinigami_whirling_slash_stop_movement:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	return state
end

function modifier_shinigami_whirling_slash_stop_movement:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			}
	return funcs
end

if IsServer() then
	function modifier_shinigami_whirling_slash_stop_movement:GetModifierPreAttack_BonusDamage()
		return self:GetStackCount()
	end
end