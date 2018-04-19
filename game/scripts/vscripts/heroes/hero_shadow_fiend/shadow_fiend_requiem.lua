shadow_fiend_requiem = class({})
LinkLuaModifier( "modifier_shadow_fiend_requiem","heroes/hero_shadow_fiend/shadow_fiend_requiem.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_fiend_requiem_passive","heroes/hero_shadow_fiend/shadow_fiend_requiem.lua",LUA_MODIFIER_MOTION_NONE )

function shadow_fiend_requiem:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Nevermore.RequiemOfSoulsCast", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {[5]="attach_attack1", [6]="attach_attack2", [7]="attach_hitloc"})
	self:GetCaster():AddNewModifier(self:GetCaster(), hAbility, "modifier_phased", {})

	return true
end

function shadow_fiend_requiem:OnSpellStart()
	local caster = self:GetCaster()
	StopSoundOn("Hero_Nevermore.RequiemOfSoulsCast", caster)

	caster:RemoveModifierByName("modifier_phased")

	self.damage = self:GetTalentSpecialValueFor("damage")

	self:ReleaseSouls()
end

function shadow_fiend_requiem:ReleaseSouls(bDeath)
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()

	local distance = self:GetTalentSpecialValueFor("radius")
	local speed = self:GetTalentSpecialValueFor("speed")

	local modifier = caster:FindModifierByName("modifier_shadow_fiend_necro")
	local necromastery = caster:FindAbilityByName("shadow_fiend_necro")
	
	local souls = 0
	
	if modifier then
		souls = modifier:GetStackCount()
	end
	
	self.damage = ( self.damage or self:GetTalentSpecialValueFor("damage") ) * souls
	local projectiles = math.floor(necromastery:GetTalentSpecialValueFor("max_souls") / 2)
	if bDeath then projectiles = math.floor(projectiles) / 2 end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf", PATTACH_ABSORIGIN, caster, {[1]=Vector(projectiles, 0, 0),[2]=caster:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN, caster, {[1]=Vector(projectiles, 0, 0)})

	local angle = 360/projectiles

	if caster:FindAbilityByName("shadow_fiend_necro"):GetToggleState() then
		local cost = self:GetTalentSpecialValueFor("soul_cost")
		local newStackCount = modifier:GetStackCount() - cost
		modifier:SetStackCount(newStackCount)
		if modifier:GetStackCount() < 1 then caster:RemoveModifierByName("modifier_shadow_fiend_necro") end

		self.damage = self.damage + self:GetTalentSpecialValueFor("soul_cost") * caster:FindAbilityByName("shadow_fiend_necro"):GetTalentSpecialValueFor("damage") * 2
	end
	EmitSoundOn("Hero_Nevermore.RequiemOfSouls", caster)
	for i=0, projectiles do
		direction = RotateVector2D(direction, ToRadians( angle ) )
		
		local particle_lines_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_lines_fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_lines_fx, 1, direction*speed)
		ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, distance/speed, 0))
		ParticleManager:ReleaseParticleIndex(particle_lines_fx)

		self:FireLinearProjectile("", direction*speed, distance, self:GetTalentSpecialValueFor("width_start"), {width_end=self:GetTalentSpecialValueFor("width_end"), extraData={secondProj=false}}, false, true, self:GetTalentSpecialValueFor("width_end"))
	end
end

function shadow_fiend_requiem:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	local caster = self:GetCaster()
	local secondProj = extraData.secondProj

	if secondProj == 0 then
		secondProj = false
	else
		secondProj = true
	end

	if hTarget then
		EmitSoundOn("Hero_Nevermore.RequiemOfSouls.Damage", hTarget)

		hTarget:AddNewModifier(caster, self, "modifier_shadow_fiend_requiem", {Duration = self:GetTalentSpecialValueFor("reduction_duration")})
		
		if secondProj and caster:HasTalent("special_bonus_unique_shadow_fiend_requiem_1") then
			self:DealDamage(caster, hTarget, self.damage/2, {}, 0)
		elseif caster:HasTalent("special_bonus_unique_shadow_fiend_requiem_2") then
			caster:Lifesteal(self, caster:FindTalentValue("special_bonus_unique_shadow_fiend_requiem_2"), self.damage, hTarget, self:GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY)
		else
			self:DealDamage(caster, hTarget, self.damage, {}, 0)
		end

	else
		if not secondProj and caster:HasTalent("special_bonus_unique_shadow_fiend_requiem_1") then
			local direction = -CalculateDirection(vLocation, caster:GetAbsOrigin())
			local speed = self:GetTalentSpecialValueFor("speed")
			local distance = self:GetTalentSpecialValueFor("radius")

			local dummy = caster:CreateDummy(vLocation, 0.5)
			local particle_lines_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
		    ParticleManager:SetParticleControl(particle_lines_fx, 0, vLocation)
		    ParticleManager:SetParticleControl(particle_lines_fx, 1, direction*speed)
		    ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, distance/speed, 0))
			ParticleManager:ReleaseParticleIndex(particle_lines_fx)

			self:FireLinearProjectile("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", direction*speed, distance, self:GetTalentSpecialValueFor("width_start"), {orign=vlocation,source=dummy,width_end=self:GetTalentSpecialValueFor("width_end"),extraData={secondProj=true}}, false, true, self:GetTalentSpecialValueFor("width_end"))
		end
	end
end

modifier_shadow_fiend_requiem = class({})
function modifier_shadow_fiend_requiem:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			 MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
    return funcs
end

function modifier_shadow_fiend_requiem:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("reduction_ms")
end

function modifier_shadow_fiend_requiem:GetModifierDamageOutgoing_Percentage()
    return self:GetTalentSpecialValueFor("reduction_damage")
end

function modifier_shadow_fiend_requiem:IsDebuff()
    return true
end