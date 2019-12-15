gyro_bombing_run = class({})
LinkLuaModifier( "modifier_valkyrie", "heroes/hero_gyro/gyro_bombing_run.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_valkyrie_aoe", "heroes/hero_gyro/gyro_bombing_run.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_valkyrie_slow", "heroes/hero_gyro/gyro_bombing_run.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function gyro_bombing_run:IsStealable()
	return true
end

function gyro_bombing_run:IsHiddenWhenStolen()
	return false
end

function gyro_bombing_run:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("max_distance")
end

function gyro_bombing_run:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Techies.Attack", caster)

	local speed = self:GetTalentSpecialValueFor("speed")/100
	local casterSpeed = caster:GetBaseMoveSpeed() + caster:GetBaseMoveSpeed()*speed
	local distance = (caster:GetAbsOrigin() - self:GetCursorPosition()):Length2D()

	local duration = distance/casterSpeed

	caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
	caster:AddNewModifier(caster, self, "modifier_valkyrie", { duration = duration })
	caster:MoveToPosition(self:GetCursorPosition())
end

modifier_valkyrie = class({})
function modifier_valkyrie:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.25)
		self.duration = self:GetSpecialValueFor("duration")
		local aoe = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_valkyrie_aoe", {Duration = duartion}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeam(), false)	
	end
end

function modifier_valkyrie:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING] = true
				}
	return state
end

function modifier_valkyrie:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_valkyrie:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("speed")
end

function modifier_valkyrie:OnIntervalThink()
	local aoe = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_valkyrie_aoe", {Duration = self.duration}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeam(), false)
	
	if IsServer() then
		if self:GetCaster():HasTalent("special_bonus_unique_gyro_bombing_run_2") then
			local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetCaster():GetAttackRange())
			for _,enemy in pairs(enemies) do
				self:GetCaster():PerformAttack(enemy, true, true, true, true, true, false, false)
				break
			end
		end
	end
end

function modifier_valkyrie:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_firefly_ember.vpcf"
end

modifier_valkyrie_aoe = class({})
function modifier_valkyrie_aoe:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_Techies.LandMine.Detonate", self:GetParent())
		self:StartIntervalThink(FrameTime())

		nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ac/ac_valkyrie_explosion.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 1, Vector(self:GetTalentSpecialValueFor("radius"),self:GetTalentSpecialValueFor("radius"),self:GetTalentSpecialValueFor("radius")))

		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			enemy:ApplyKnockBack(self:GetParent():GetAbsOrigin(), 0.5, 0.5, self:GetTalentSpecialValueFor("radius"), 0, self:GetCaster(), self:GetAbility())
			self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
end

function modifier_valkyrie_aoe:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(nfx, false)
	end
end

function modifier_valkyrie_aoe:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_valkyrie_slow", {Duration = 0.5})
	end
end

modifier_valkyrie_slow = class({})
function modifier_valkyrie_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_valkyrie_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("reduc_move_speed")
end