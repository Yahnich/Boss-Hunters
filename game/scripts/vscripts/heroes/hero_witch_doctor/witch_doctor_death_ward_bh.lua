witch_doctor_death_ward_bh = class({})

function witch_doctor_death_ward_bh:GetChannelTime()
	if self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_death_ward_2") then
		return 0
	else
		return self:GetTalentSpecialValueFor("total_duration")
	end
end

function witch_doctor_death_ward_bh:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local vPosition = self:GetCursorPosition()
		self.wardDamage = self:GetTalentSpecialValueFor("damage") + caster:GetIntellect()*self:GetTalentSpecialValueFor("int_to_damage")/100
		self.death_ward = CreateUnitByName("witch_doctor_death_ward_ebf", vPosition, true, caster, nil, caster:GetTeam())
		self.death_ward:SetControllableByPlayer(caster:GetPlayerID(), true)
		self.death_ward:SetOwner(caster)
		self.death_ward:SetBaseAttackTime( self:GetTalentSpecialValueFor("base_attack_time") )
		self.deathModifier = self.death_ward:AddNewModifier(caster, self, "modifier_death_ward_handling", {duration = self:GetTalentSpecialValueFor("total_duration")})
		EmitSoundOn("Hero_WitchDoctor.Death_WardBuild", self.death_ward)

		self.death_ward:SetAverageBaseDamage( self.wardDamage, 25)
	end
end

function witch_doctor_death_ward_bh:OnChannelFinish()
	self.deathModifier:Destroy()
end

function witch_doctor_death_ward_bh:OnProjectileHit_ExtraData(target, vLocation, extraData)
	if not self.death_ward:IsNull() then
		local fixedDamage = self.wardDamage - self:GetCaster():GetAttackDamage()
		self:GetCaster():PerformAbilityAttack(target, self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_death_ward_1"), self, fixedDamage, false, false)
		if extraData.bounces_left > 0 and self:GetCaster():HasScepter() then
			extraData.bounces_left = extraData.bounces_left - 1
			extraData[tostring(target:GetEntityIndex())] = 1
			self:CreateBounceAttack(target, extraData)
		end
	end
end

function witch_doctor_death_ward_bh:CreateBounceAttack(originalTarget, extraData)
    local caster = self:GetCaster()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), originalTarget:GetAbsOrigin(), nil, 900,
                    self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
                    0, FIND_CLOSEST, false)
    local target = originalTarget
    for _,enemy in pairs(enemies) do
        if extraData[tostring(enemy:GetEntityIndex())] ~= 1 and not enemy:IsAttackImmune() and extraData.bounces_left > 0 then
			extraData[tostring(enemy:GetEntityIndex())] = 1
		    local projectile = {
				Target = enemy,
				Source = originalTarget,
				Ability = self,
				EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf",
				bDodgable = true,
				bProvidesVision = false,
				iMoveSpeed = 1500,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				ExtraData = extraData
			}
			ProjectileManager:CreateTrackingProjectile(projectile)
            extraData.bounces_left = extraData.bounces_left - 1
        end
    end
	EmitSoundOn("Hero_Jakiro.Attack" ,originalTarget)
end

LinkLuaModifier("modifier_death_ward_handling", "lua_abilities/heroes/witch_doctor", LUA_MODIFIER_MOTION_NONE)
modifier_death_ward_handling = class({})

function modifier_death_ward_handling:OnCreated()
	self.wardParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
		ParticleManager:SetParticleControlEnt(self.wardParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.wardParticle, 2, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.wardParticle)
	if IsServer() then
		self:StartIntervalThink( self:GetParent():GetBaseAttackTime() )
	end
end

function modifier_death_ward_handling:OnIntervalThink()
	if IsServer() then
		local attack_range = 700
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, attack_range, self:GetAbility():GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, 1, false)
		local bounces = 0
		if self:GetCaster():HasScepter() then bounces = self:GetAbility():GetTalentSpecialValueFor("bounces_scepter") end
		for _, unit in pairs(units) do
			local projectile = {
				Target = unit,
				Source = self:GetParent(),
				Ability = self:GetAbility(),
				EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf",
				bDodgable = true,
				bProvidesVision = false,
				iMoveSpeed = self:GetParent():GetProjectileSpeed(),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				ExtraData = {bounces_left = bounces, [tostring(unit:GetEntityIndex())] = 1}
			}
			EmitSoundOn("Hero_WitchDoctor_Ward.Attack", self:GetParent())
			ProjectileManager:CreateTrackingProjectile(projectile)
			break
		end
	end
end

function modifier_death_ward_handling:OnDestroy()
	if IsServer() then
		StopSoundEvent("Hero_WitchDoctor.Death_WardBuild", self.death_ward)
		UTIL_Remove(self.death_ward)	
	end
end

function modifier_death_ward_handling:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
	}
	return state
end