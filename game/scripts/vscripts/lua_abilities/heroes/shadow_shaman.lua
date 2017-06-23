shadow_shaman_ether_lightning = class({})


function shadow_shaman_ether_lightning:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local start_radius = self:GetSpecialValueFor("start_radius")
	local end_radius = self:GetSpecialValueFor("end_radius")
	local end_distance = self:GetSpecialValueFor("end_distance")
	local zapTargets = self:GetSpecialValueFor("targets")
	local damage = self:GetSpecialValueFor("damage")
	local damage_type = self:GetAbilityDamageType()
	local particleName = "particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf"
	local zappedTargets = {}
	
	EmitSoundOn("Hero_ShadowShaman.EtherShock", hCaster)
	
	local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, hCaster)
	ParticleManager:SetParticleControl(lightningBolt,0,Vector(hCaster:GetAbsOrigin().x,hCaster:GetAbsOrigin().y,hCaster:GetAbsOrigin().z + hCaster:GetBoundingMaxs().z ))	
	ParticleManager:SetParticleControl(lightningBolt,1,Vector(hTarget:GetAbsOrigin().x,hTarget:GetAbsOrigin().y,hTarget:GetAbsOrigin().z + hTarget:GetBoundingMaxs().z ))
	ParticleManager:ReleaseParticleIndex(lightningBolt)
	
	ApplyDamage({ victim = hTarget, attacker = hCaster, damage = damage, damage_type = damage_type, ability = self})
	hTarget:EmitSound("Hero_ShadowShaman.EtherShock.Target")
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
				ApplyDamage({ victim = unit, attacker = hCaster, damage = damage, damage_type = damage_type, ability = self})
				hTarget:EmitSound("Hero_ShadowShaman.EtherShock.Target")

				-- Increment counter
				
				zapTargets = zapTargets - 1
				table.insert(zappedTargets, unit)
				if hTarget:HasModifier("shaman_le_voodoo") then
				end
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
						ApplyDamage({ victim = zapTarget, attacker = hCaster, damage = damage, damage_type = damage_type, ability = self})
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


shadow_shaman_ignited_voodoo = class({})


function shadow_shaman_ignited_voodoo:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local hCaster = self:GetCaster()
	
	-- cosmetic
	hTarget:EmitSound("Hero_ShadowShaman.Hex.Target")
	local voodooPoof = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf", PATTACH_POINT_FOLLOW, hTarget)
	ParticleManager:ReleaseParticleIndex(voodooPoof)
	
	if hTarget:IsIllusion() then
		hTarget:ForceKill(true)
	else
		hTarget:AddNewModifier(hCaster, self, "modifier_shadow_shaman_ignited_voodoo", {duration = self:GetSpecialValueFor("duration")})
	end
end

LinkLuaModifier("modifier_shadow_shaman_ignited_voodoo", "lua_abilities/heroes/shadow_shaman.lua", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_ignited_voodoo = class({})

function modifier_shadow_shaman_ignited_voodoo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_shadow_shaman_ignited_voodoo:GetModifierModelChange()
	return "models/props_gameplay/chicken.vmdl"
end

function modifier_shadow_shaman_ignited_voodoo:GetModifierModelScale()
	return -50
end

function modifier_shadow_shaman_ignited_voodoo:GetModifierMoveSpeedOverride()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_shadow_shaman_ignited_voodoo:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_HEXED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function modifier_shadow_shaman_ignited_voodoo:OnCreated()
end

function modifier_shadow_shaman_ignited_voodoo:OnDestroy()
	if IsServer() then
		local parentPos = self:GetParent():GetAbsOrigin()
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		EmitSoundOn("Hero_Techies.Suicide", self:GetParent())
		local voodooBoom = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(voodooBoom,0,parentPos)
		ParticleManager:SetParticleControl(voodooBoom,1,Vector(radius/2,0,0 ))
		ParticleManager:SetParticleControl(voodooBoom,2,Vector(radius,radius,radius ))
		ParticleManager:ReleaseParticleIndex(voodooBoom)
		
		self:GetCaster():DealAOEDamage(parentPos, radius, {damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
end



shadow_shaman_binding_shackle = class({})

function shadow_shaman_binding_shackle:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local hCaster = self:GetCaster()
	self.shackleTarget = hTarget
	
	-- cosmetic
	EmitSoundOn("Hero_ShadowShaman.Shackles.Cast", hCaster)

	
	if hTarget:IsIllusion() then
		hTarget:ForceKill(true)
	else
		hTarget:AddNewModifier(hCaster, self, "modifier_shadow_shaman_bound_shackles", {duration = self:GetSpecialValueFor("channel_time")})
	end
end


LinkLuaModifier("modifier_shadow_shaman_bound_shackles", "lua_abilities/heroes/shadow_shaman.lua", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_bound_shackles = class({})

function modifier_shadow_shaman_bound_shackles:OnCreated()
	self.duration = self:GetRemainingTime()
	self.damage = self:GetAbility():GetSpecialValueFor("total_damage")
	self.tick = self:GetAbility():GetSpecialValueFor("tick_interval")
	EmitSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:StartIntervalThink(self.tick)
	end
	local shackles = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(shackles, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	
	ParticleManager:SetParticleControlEnt(shackles, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	
	self:AddParticle(shackles, false, false, 10, false, false)
end

function modifier_shadow_shaman_bound_shackles:OnIntervalThink()
	if not self:GetCaster():IsChanneling() then self:Destroy() end
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = (self.damage/self.duration)*self.tick, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_shadow_shaman_bound_shackles:OnDestroy()
	StopSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:GetCaster():InterruptChannel()
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_shaman_bound_shackles_post", {duration = self:GetAbility():GetSpecialValueFor("aftershackle_duration")})
	end
end

function modifier_shadow_shaman_bound_shackles:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}

	return funcs
end

function modifier_shadow_shaman_bound_shackles:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_shadow_shaman_bound_shackles:GetStatusEffectName()
	return "particles/status_fx/status_effect_shaman_shackle.vpcf"
end

function modifier_shadow_shaman_bound_shackles:StatusEffectPriority()
	return 10
end


function modifier_shadow_shaman_bound_shackles:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

LinkLuaModifier("modifier_shadow_shaman_bound_shackles_post", "lua_abilities/heroes/shadow_shaman.lua", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_bound_shackles_post = class({})

function modifier_shadow_shaman_bound_shackles_post:OnCreated()
	self.duration = self:GetRemainingTime()
	self.damage = self:GetAbility():GetSpecialValueFor("total_damage")
	self.tick = self:GetAbility():GetSpecialValueFor("tick_interval")
	EmitSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:StartIntervalThink(self.tick)
	end
	local shackles = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(shackles, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	
	ParticleManager:SetParticleControlEnt(shackles, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
	
	self:AddParticle(shackles, false, false, 10, false, false)
end

function modifier_shadow_shaman_bound_shackles_post:OnIntervalThink()
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = (self.damage/self.duration)*self.tick, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_shadow_shaman_bound_shackles_post:OnDestroy()
	StopSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
end

function modifier_shadow_shaman_bound_shackles_post:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}

	return funcs
end

function modifier_shadow_shaman_bound_shackles_post:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_shadow_shaman_bound_shackles_post:GetStatusEffectName()
	return "particles/status_fx/status_effect_shaman_shackle.vpcf"
end

function modifier_shadow_shaman_bound_shackles_post:StatusEffectPriority()
	return 10
end


function modifier_shadow_shaman_bound_shackles_post:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
