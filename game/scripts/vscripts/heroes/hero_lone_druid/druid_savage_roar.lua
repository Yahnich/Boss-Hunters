druid_savage_roar = class({})

function druid_savage_roar:IsStealable()
    return true
end

function druid_savage_roar:IsHiddenWhenStolen()
    return false
end

function druid_savage_roar:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("radius")
end

function druid_savage_roar:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetTalentSpecialValueFor("duration")
	local damage = self:GetTalentSpecialValueFor("damage")
	local radius = self:GetTalentSpecialValueFor("radius")
	local talent2 = caster:HasTalent("special_bonus_unique_druid_savage_roar_2")
	local talent1 = caster:HasTalent("special_bonus_unique_druid_savage_roar_1")
	local minionMultiplier = caster:FindTalentValue("special_bonus_unique_druid_savage_roar_2")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT, "attach_mouth", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
	caster:EmitSound("Hero_LoneDruid.SavageRoar.Cast")
	
	if caster.bear then -- is druid
		local roar = caster.bear:FindAbilityByName("druid_savage_roar")
		if not roar then
			roar = caster.bear:AddAbility("druid_savage_roar")
		end
		roar:SetLevel( self:GetLevel() )
		if roar and roar:IsCooldownReady() then
			roar:CastSpell( )
		end
	else
		local druid = PlayerResource:GetSelectedHeroEntity( caster:GetPlayerOwnerID() )
		local roar = druid:FindAbilityByName("druid_savage_roar")
		if roar and roar:IsCooldownReady() then
			roar:CastSpell( )
		end
	end
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			local dur = duration
			if talent2 and enemy:IsMinion() then
				dur = duration * minionMultiplier
			end
			if not enemy.loneDruidSavageRoar or enemy.loneDruidSavageRoar:IsNull() then
				enemy.loneDruidSavageRoar = enemy:Fear(self, caster, dur)
			else
				local params = {caster = caster, target = enemy, duration = dur, ability = self, modifier_name = "modifier_generic_fear	"}
				enemy.loneDruidSavageRoar:SetDuration( enemy.loneDruidSavageRoar:GetRemainingTime() + dur * caster:GetStatusAmplification( params ), true )
			end
			if talent1 then
				local modifier = enemy:FindModifierByName("modifier_druid_savage_roar_talent")
				if modifier then
					modifier:SetDuration( modifier:GetRemainingTime() + enemy.loneDruidSavageRoar:GetRemainingTime(), true )
				else
					enemy:AddNewModifier( caster, self, "modifier_druid_savage_roar_talent", {duration = enemy.loneDruidSavageRoar:GetRemainingTime(), ignoreStatusAmp = true} )
				end
			end
			self:DealDamage( caster, enemy, damage )
		end
	end
end

modifier_druid_savage_roar_talent = class({})
LinkLuaModifier("modifier_druid_savage_roar_talent", "heroes/hero_lone_druid/druid_savage_roar", LUA_MODIFIER_MOTION_NONE)

function modifier_druid_savage_roar_talent:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_druid_savage_roar_1", "slow")
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_druid_savage_roar_1", "amp")
end

function modifier_druid_savage_roar_talent:OnRefresh(kv)
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_druid_savage_roar_1", "slow")
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_druid_savage_roar_1", "amp")
	self:SetDuration( self:GetRemainingTime() )
end

function modifier_druid_savage_roar_talent:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_druid_savage_roar_talent:GetModifierIncomingDamage_Percentage()
	return self.amp
end

function modifier_druid_savage_roar_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_druid_savage_roar_talent:IsHidden()
	return true
end