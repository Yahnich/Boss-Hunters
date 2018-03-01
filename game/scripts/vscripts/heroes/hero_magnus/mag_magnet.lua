mag_magnet = class({})
LinkLuaModifier( "modifier_mag_magnet", "heroes/hero_magnus/mag_magnet.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mag_magnet_damage", "heroes/hero_magnus/mag_magnet.lua", LUA_MODIFIER_MOTION_NONE )

function mag_magnet:IsStealable()
    return true
end

function mag_magnet:IsHiddenWhenStolen()
    return false
end

function mag_magnet:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function mag_magnet:OnSpellStart()
	EmitSoundOn("Hero_Magnataur.Empower.Cast", self:GetCaster())

	local tower = self:GetCaster():CreateSummon("npc_magnus_magnet", self:GetCursorPosition(), self:GetTalentSpecialValueFor("duration"))
	EmitSoundOn("Hero_Magnataur.Empower.Target", tower)
	FindClearSpaceForUnit(tower, tower:GetAbsOrigin(), true)
	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_tombstone_spawn.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=tower:GetAbsOrigin()})
	tower:AddNewModifier(self:GetCaster(), self, "modifier_mag_magnet", {})
end

modifier_mag_magnet = class({})
function modifier_mag_magnet:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_mag_magnet:OnIntervalThink()
	local parent = self:GetParent()
	local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if self:GetCaster():HasTalent("special_bonus_unique_mag_magnet_2") and RollPercentage(2) then
			self:GetAbility():Stun(enemy, 0.25, false)
		end
		if not enemy:IsKnockedBack() or not enemy:IsStunned() then
			local distance = CalculateDistance(parent, enemy)
			local dir = CalculateDirection(parent, enemy)
			if distance > 100 then
				enemy:SetAbsOrigin(GetGroundPosition(enemy:GetAbsOrigin(), enemy)+dir*self:GetSpecialValueFor("strength"))
				FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), true)
			end
		end
	end
end

function modifier_mag_magnet:CheckState()
	local state = { --[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					--[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					--[MODIFIER_STATE_OUT_OF_GAME] = true,
					}
	return state
end

function modifier_mag_magnet:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_mag_magnet:OnDeath(params)
    if IsServer() and params.unit == self:GetParent() then
    	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_tombstone_spawn.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=params.unit:GetAbsOrigin()})
    	self:GetParent():AddNoDraw()
    	self:Destroy()
    end
end

function modifier_mag_magnet:GetEffectName()
    return "particles/units/heroes/hero_magnus/magnus_magnet_wave.vpcf"
end

function modifier_mag_magnet:IsAura()
	if self:GetCaster():HasTalent("special_bonus_unique_mag_magnet_1") then
   		return true
   	else
   		return false
   	end
end

function modifier_mag_magnet:GetAuraDuration()
    return 0.5
end

function modifier_mag_magnet:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_mag_magnet:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_mag_magnet:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_mag_magnet:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_mag_magnet:GetModifierAura()
    return "modifier_mag_magnet_damage"
end

function modifier_mag_magnet:IsAuraActiveOnDeath()
    return false
end

modifier_mag_magnet_damage = class({})
function modifier_mag_magnet_damage:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_mag_magnet_damage:OnIntervalThink()
	local damage = self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), 50, {damage_type=DAMAGE_TYPE_PHYSICAL}, 0)
end