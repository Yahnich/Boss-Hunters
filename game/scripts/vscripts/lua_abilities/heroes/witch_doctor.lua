witch_doctor_paralyzing_cask_ebf = class({})

function witch_doctor_paralyzing_cask_ebf:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local projectile = {
			Target = hTarget,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
			bDodgable = true,
			bProvidesVision = false,
			iMoveSpeed = self:GetSpecialValueFor("speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		}
	local bounces = self:GetSpecialValueFor("bounces") + 1
	if not self.remainingBounces then self.remainingBounces = bounces
	else self.remainingBounces = self.remainingBounces + bounces end -- Adds bounces on refresh; can be commented out
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Cast", self:GetCaster())
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function witch_doctor_paralyzing_cask_ebf:OnProjectileHit(target, vLocation)
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Bounce", target)
	local bounce_delay  = self:GetSpecialValueFor("bounce_delay")
	local bounce_range = self:GetSpecialValueFor("bounce_range")
	local caster = self:GetCaster()
	if not target then return end
	if target:IsRealHero() then
		if self.remainingBounces then self.remainingBounces = self.remainingBounces - 1 end
		local healdmg = self:GetSpecialValueFor("hero_damage")
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			target:AddNewModifier(target, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("hero_duration")})
			ApplyDamage({victim = target, attacker = caster, damage = healdmg, damage_type = self:GetAbilityDamageType()})
		else
			target:Heal(healdmg, caster)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, healdmg, nil)
		end
	else
		local healdmg_creep = self:GetSpecialValueFor("creep_damage")
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			target:AddNewModifier(target, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("creep_duration")})
			ApplyDamage({victim = target, attacker = caster, damage = healdmg_creep, damage_type = self:GetAbilityDamageType()})
		else
			target:Heal(healdmg_creep, caster)
			SendOverheadEventMessage(target, OVERHEAD_ALERT_HEAL, target, healdmg_creep, target)
		end
	end
	if self.remainingBounces and self.remainingBounces > 0 then
		-- We wait on the delay
		Timers:CreateTimer(bounce_delay,
		function()
			-- Finds all units in the area
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, bounce_range, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), 0, 0, false)
			-- Go through the target_enties table, checking for the first one that isn't the same as the target
			local target_to_jump = {}
			for _,unit in pairs(units) do
				if unit ~= target then
					table.insert(target_to_jump, unit)
					break
				end
			end
			if #target_to_jump == 0 then 
				self.remainingBounces = nil
				return
			end
			for _, jumpTarget in pairs(target_to_jump) do
				local projectile = {
					Target = jumpTarget,
					Source = target,
					Ability = self,
					EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
					bDodgable = true,
					bProvidesVision = false,
					iMoveSpeed = self:GetSpecialValueFor("speed"),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				}
				ProjectileManager:CreateTrackingProjectile(projectile)
			end
		end)
	else
		self.remainingBounces = nil
	end
end


witch_doctor_voodoo_restoration_ebf = class({})

function witch_doctor_voodoo_restoration_ebf:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

LinkLuaModifier("witch_doctor_voodoo_restoration_ebf_handler", "lua_abilities/heroes/witch_doctor", LUA_MODIFIER_MOTION_NONE)
function witch_doctor_voodoo_restoration_ebf:OnToggle()
	if self:GetToggleState() then
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration", self:GetCaster())
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Loop", self:GetCaster())
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "witch_doctor_voodoo_restoration_ebf_handler", {})
	else
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Off", self:GetCaster())
		StopSoundEvent("Hero_WitchDoctor.Voodoo_Restoration.Loop", self:GetCaster())
		self:GetCaster():RemoveModifierByName("witch_doctor_voodoo_restoration_ebf_handler")
	end
end

witch_doctor_voodoo_restoration_ebf_handler = class({})

function witch_doctor_voodoo_restoration_ebf_handler:OnCreated()
	self.interval = self:GetAbility():GetSpecialValueFor("heal_interval")
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
	self.manaCost = self:GetAbility():GetSpecialValueFor("mana_per_second") * self.interval
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.mainParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(self.mainParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.mainParticle, 1, Vector( self.radius, self.radius, self.radius ) )
			ParticleManager:SetParticleControlEnt(self.mainParticle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
end

function witch_doctor_voodoo_restoration_ebf_handler:OnDestroy()
	if IsServer() then
		self:StartIntervalThink(-1)
	end
	ParticleManager:DestroyParticle(self.mainParticle, false)
	ParticleManager:ReleaseParticleIndex(self.mainParticle)
end

function witch_doctor_voodoo_restoration_ebf_handler:OnIntervalThink()
	if self:GetCaster():GetMana() >= self:GetAbility():GetManaCost(-1) then
		self:GetCaster():SpendMana(self.manaCost, self:GetAbility())
	else
		self:GetAbility():ToggleAbility()
	end
end

function witch_doctor_voodoo_restoration_ebf_handler:IsAura()
	return true
end

function witch_doctor_voodoo_restoration_ebf_handler:IsAuraActiveOnDeath()
	return false
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraRadius()
	return self.radius
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function witch_doctor_voodoo_restoration_ebf_handler:GetModifierAura()
	return "witch_doctor_voodoo_restoration_ebf_heal"
end

function witch_doctor_voodoo_restoration_ebf_handler:IsHidden()
	return true
end

LinkLuaModifier("witch_doctor_voodoo_restoration_ebf_heal", "lua_abilities/heroes/witch_doctor", LUA_MODIFIER_MOTION_NONE)
witch_doctor_voodoo_restoration_ebf_heal = class({})

function witch_doctor_voodoo_restoration_ebf_heal:OnCreated()
	self.interval = self:GetAbility():GetSpecialValueFor("heal_interval")
	self.burstHeal = self:GetAbility():GetSpecialValueFor("cleanse_heal") / 100
	if IsServer() then
		self:StartIntervalThink( self.interval )
		self.heal = (self:GetAbility():GetTalentSpecialValueFor("heal") + self:GetCaster():GetIntellect()*self:GetAbility():GetSpecialValueFor("int_to_heal")/100 ) * self.interval
		self.purgeCounter = 0
		self.purgeTimer = self:GetAbility():GetSpecialValueFor("cleanse_interval")
	end
	self.stickTime = 0.5
	self:SetDuration(self.stickTime, false)
end

function witch_doctor_voodoo_restoration_ebf_heal:OnRefresh()
	self.burstHeal = self:GetAbility():GetSpecialValueFor("cleanse_heal") / 100
	if IsServer() then
		self.heal = (self:GetAbility():GetTalentSpecialValueFor("heal") + self:GetCaster():GetIntellect()*self:GetAbility():GetSpecialValueFor("int_to_heal")/100 ) * self.interval
	end
	self:SetDuration(self.stickTime, false)
end

function witch_doctor_voodoo_restoration_ebf_heal:IsBuff()
	return true
end


function witch_doctor_voodoo_restoration_ebf_heal:OnIntervalThink()
	self:GetParent():Heal(self.heal, self:GetCaster())
	SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_HEAL, self:GetParent(), self.heal, self:GetParent())
	self.purgeCounter = self.purgeCounter + self.interval
	if self.purgeCounter > self.purgeTimer then
		EmitSoundOn("Hero_WitchDoctor.Attack", self:GetParent())
		local burst = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(burst, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(burst)
		self:GetParent():Heal(self:GetParent():GetMaxHealth()*self.burstHeal, self:GetCaster())
		self.purgeCounter = 0
	end
end

witch_doctor_death_ward_ebf = class({})

function witch_doctor_death_ward_ebf:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local vPosition = self:GetCursorPosition()
		self.wardDamage = self:GetSpecialValueFor("damage") + caster:GetIntellect()*self:GetSpecialValueFor("int_to_damage")/100
		self.death_ward = CreateUnitByName("witch_doctor_death_ward_ebf", vPosition, true, caster, nil, caster:GetTeam())
		self.death_ward:SetControllableByPlayer(caster:GetPlayerID(), true)
		self.death_ward:SetOwner(caster)
		self.death_ward:SetBaseAttackTime( self:GetSpecialValueFor("base_attack_time") )
		self.death_ward:AddNewModifier(caster, self, "modifier_death_ward_handling", {duration = self:GetChannelTime()})
		EmitSoundOn("Hero_WitchDoctor.Death_WardBuild", self.death_ward)
		local exceptionList = {["item_starfury"] = true,}
		for i = 0, 5 do
			local item = caster:GetItemInSlot(i)
			if item and not exceptionList[item:GetName()] then
				self.death_ward:AddItemByName(item:GetName())
			end
		end
		local damageOffset = self.death_ward:GetAverageTrueAttackDamage(self.death_ward)
		self.death_ward:SetBaseDamageMax( self.wardDamage - damageOffset )
		self.death_ward:SetBaseDamageMin( self.wardDamage - damageOffset )
	end
end

function witch_doctor_death_ward_ebf:OnChannelFinish()
	if IsServer() then
		StopSoundEvent("Hero_WitchDoctor.Death_WardBuild", self.death_ward)
		UTIL_Remove(self.death_ward)	
	end
end

function witch_doctor_death_ward_ebf:OnProjectileHit_ExtraData(target, vLocation, extraData)
	if not self.death_ward:IsNull() then
		self.death_ward:PerformAttack(target, false, true, true, true, false)
		if extraData.bounces_left > 0 and self:GetCaster():HasScepter() then
			extraData.bounces_left = extraData.bounces_left - 1
			extraData[tostring(target:GetEntityIndex())] = 1
			self:CreateBounceAttack(target, extraData)
		end
	end
end

function witch_doctor_death_ward_ebf:CreateBounceAttack(originalTarget, extraData)
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
		if self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_1") then attack_range = attack_range + self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_1") end
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, attack_range, self:GetAbility():GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, 1, false)
		local bounces = 0
		if self:GetCaster():HasScepter() then bounces = self:GetAbility():GetSpecialValueFor("bounces_scepter") end
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

function modifier_death_ward_handling:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end