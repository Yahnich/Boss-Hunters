witch_doctor_death_ward_bh = class({})

function witch_doctor_death_ward_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror") then
		return "custom/witch_doctor_death_ward_heal"
	else
		return "witch_doctor_death_ward"
	end
end

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
		
		duration = -1
		if caster:HasTalent("special_bonus_unique_witch_doctor_death_ward_2") then
			duration = self:GetTalentSpecialValueFor("total_duration")
		end
		self.deathModifier = self.death_ward:AddNewModifier(caster, self, "modifier_death_ward_handling", {duration = duration})
		EmitSoundOn("Hero_WitchDoctor.Death_WardBuild", self.death_ward)

		self.death_ward:SetAverageBaseDamage( self.wardDamage, 25)
	end
end

function witch_doctor_death_ward_bh:OnChannelFinish()
	self.deathModifier:Destroy()
end

function witch_doctor_death_ward_bh:OnProjectileHit_ExtraData(target, vLocation, extraData)
	if not self.death_ward:IsNull() then
		local caster = self:GetCaster()
		if target:IsSameTeam( caster ) then
			local healing = self:GetTalentSpecialValueFor("healing")
			target:HealEvent( healing, self, caster )
		else
			local damage = self:GetTalentSpecialValueFor("damage")
			self:DealDamage( caster, target, damage )
		end
		if extraData.bounces_left > 0 then
			extraData[tostring(target:GetEntityIndex())] = 1
			self:CreateBounceAttack(target, extraData)
		end
		EmitSoundOn("Hero_WitchDoctor_Ward.Attack", target)
	end
end

function witch_doctor_death_ward_bh:CreateBounceAttack(originalTarget, extraData)
    local caster = self:GetCaster()
	if originalTarget:IsSameTeam( caster ) then
		local units = caster:FindFriendlyUnitsInRadius( originalTarget:GetAbsOrigin(), 700, {order = FIND_CLOSEST} )
		for _, ally in pairs(units) do
			print( ally:GetName(), extraData[tostring(ally:GetEntityIndex())], ally:IsAttackImmune(), ally:HasModifier("modifier_death_ward_handling") )
			if not ally:HasModifier("modifier_death_ward_handling") and extraData[tostring(ally:GetEntityIndex())] ~= 1 and not ally:IsAttackImmune() and extraData.bounces_left > 0 then
				local projectile = {
					Target = ally,
					Source = originalTarget,
					Ability = self,
					EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_heal.vpcf",
					bDodgable = true,
					bProvidesVision = false,
					iMoveSpeed = 1500,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
					ExtraData = extraData
				}
				extraData.bounces_left = extraData.bounces_left - 1
				ProjectileManager:CreateTrackingProjectile(projectile)
				break
			end
		end
	else
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), originalTarget:GetAbsOrigin(), nil, 700,
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
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
					ExtraData = extraData
				}
				extraData.bounces_left = extraData.bounces_left - 1
				ProjectileManager:CreateTrackingProjectile(projectile)
				break
			end
		end
	end
end

LinkLuaModifier("modifier_death_ward_handling", "heroes/hero_witch_doctor/witch_doctor_death_ward_bh", LUA_MODIFIER_MOTION_NONE)
modifier_death_ward_handling = class({})

function modifier_death_ward_handling:OnCreated()
	self.lastState = self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror")
	if self:GetCaster():HasScepter() then
		nFX1 = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_heal_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
		ParticleManager:SetParticleControlEnt(nFX1, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nFX1, 2, self:GetParent():GetAbsOrigin())
		self:AddEffect( nFX1 )
		ParticleManager:ReleaseParticleIndex( nFX1 )
		nFX2 = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
		ParticleManager:SetParticleControlEnt(nFX2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nFX2, 2, self:GetParent():GetAbsOrigin())
		self:AddEffect( nFX2 )
		ParticleManager:ReleaseParticleIndex( nFX2 )
	else
		if self.lastState then
			self.wardParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_heal_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
			ParticleManager:SetParticleControlEnt(self.wardParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.wardParticle, 2, self:GetParent():GetAbsOrigin())
		else
			self.wardParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
			ParticleManager:SetParticleControlEnt(self.wardParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.wardParticle, 2, self:GetParent():GetAbsOrigin())
		end
	end
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_death_ward_1")
	self.talent1Bounces = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_death_ward_1")
	if IsServer() then
		self:StartIntervalThink( self:GetParent():GetBaseAttackTime() )
	end
end

function modifier_death_ward_handling:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ward = self:GetParent()
		local ability = self:GetAbility()
		local attack_range = 700
		local bounces = 0
		if self.talent1 then bounces = self.talent1Bounces end
		if caster:HasScepter() then -- shoot both
			enemies = caster:FindEnemyUnitsInRadius( ward:GetAbsOrigin(), attack_range, {order = FIND_CLOSEST} )
			allies = caster:FindFriendlyUnitsInRadius( ward:GetAbsOrigin(), attack_range, {order = FIND_CLOSEST} )
			for _, enemy in pairs(enemies) do
				ability:FireTrackingProjectile("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf", enemy, 1500, {source = ward, extraData = {bounces_left = bounces, [tostring(enemy:GetEntityIndex())] = 1}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
				EmitSoundOn("Hero_WitchDoctor_Ward.Attack", ward)
				break
			end
			for _, ally in pairs(allies) do
				if ally ~= ward then
					ability:FireTrackingProjectile("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_heal.vpcf", ally, 1500, {source = ward, extraData = {bounces_left = bounces, [tostring(ally:GetEntityIndex())] = 1}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
					EmitSoundOn("Hero_WitchDoctor_Ward.Attack", ward)
					break
				end
			end
		else
			if self.lastState ~= self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror") then
				self.lastState = self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror")
				ParticleManager:ClearParticle( self.wardParticle, true )
				if self.lastState then
					self.wardParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_heal_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
					ParticleManager:SetParticleControlEnt(self.wardParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.wardParticle, 2, self:GetParent():GetAbsOrigin())
				else
					self.wardParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", PATTACH_POINT_FOLLOW, self:GetParent()) 
					ParticleManager:SetParticleControlEnt(self.wardParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.wardParticle, 2, self:GetParent():GetAbsOrigin())
				end
			end
			local units
			local nFX = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_heal.vpcf"
			if not self.lastState then
				units = caster:FindEnemyUnitsInRadius( ward:GetAbsOrigin(), attack_range, {order = FIND_CLOSEST} )
				nFX = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf"
			else
				units = caster:FindFriendlyUnitsInRadius( ward:GetAbsOrigin(), attack_range, {order = FIND_CLOSEST} )
			end
			for _, unit in pairs(units) do
				if unit ~= ward then
					ability:FireTrackingProjectile(nFX, unit, 900, {source = ward, extraData = {bounces_left = bounces, [tostring(unit:GetEntityIndex())] = 1}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
					EmitSoundOn("Hero_WitchDoctor_Ward.Attack", ward)
					break
				end
			end
		end
	end
end

function modifier_death_ward_handling:OnDestroy()
	if IsServer() then
		StopSoundEvent("Hero_WitchDoctor.Death_WardBuild", self:GetParent() )
		UTIL_Remove( self:GetParent() )
		if self.wardParticle then
			ParticleManager:ReleaseParticleIndex(self.wardParticle)
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
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
	}
	return state
end