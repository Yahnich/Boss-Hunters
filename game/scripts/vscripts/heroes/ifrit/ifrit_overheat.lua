ifrit_overheat = class({})

function ifrit_overheat:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_overheat_kindled"
	else
		return "custom/ifrit_overheat"
	end
end

function ifrit_overheat:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return self:GetSpecialValueFor("kindled_radius")
	else
		return 0
	end
end

function ifrit_overheat:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local damage = 0
	local duration = self:GetTalentSpecialValueFor("dot_duration")
	local radius = self:GetTalentSpecialValueFor("kindled_radius")
	
	
	if caster:HasTalent("ifrit_overheat_talent_1") then 
		if caster:HasModifier("modifier_ifrit_kindled_soul_active") then
			local AOETargets = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {})
			for _, aoeTarget in pairs(AOETargets) do
				aoeTarget:AddNewModifier(caster, self, "modifier_ifrit_overheat_fire_debuff", {duration = duration})
			end
		else
			target:AddNewModifier(caster, self, "modifier_ifrit_overheat_fire_debuff", {duration = duration})
		end
	end
	
	local modifierList = target:FindAllModifiers()
	for _, modifier in ipairs(modifierList) do
		if modifier.IsFireDebuff and modifier:IsFireDebuff() then
			damage = damage + self:GetPotentialBurst(modifier)
			modifier:Destroy()
		end
	end
	
	if damage == 0 then
		if caster:HasModifier("modifier_ifrit_kindled_soul_active") then
			local AOETargets = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {})
			for _, aoeTarget in pairs(AOETargets) do
				aoeTarget:AddNewModifier(caster, self, "modifier_ifrit_overheat_fire_debuff", {duration = duration})
			end
		else
			target:AddNewModifier(caster, self, "modifier_ifrit_overheat_fire_debuff", {duration = duration})
		end
	else
		local flamePoof = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(flamePoof, 0,target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(flamePoof)
		EmitSoundOn("Hero_DragonKnight.ElderDragonForm", target)
		
		local burst_damage = damage * self:GetTalentSpecialValueFor("dot_multiplier") / 100 + (self:GetCaster().selfImmolationDamageBonus or 0)
		if caster:HasModifier("modifier_ifrit_kindled_soul_active") then
			caster:DealAOEDamage(target:GetAbsOrigin(), radius, {ability = self, damage_type = self:GetAbilityDamageType(), damage = burst_damage})
		else
			self:DealDamage(caster, target, burst_damage)
		end
	end
end

function ifrit_overheat:GetPotentialBurst(modifier)
	local dps = modifier.damage_over_time
	local timeRemaining = modifier:GetRemainingTime()
	
	return dps*timeRemaining
end


LinkLuaModifier( "modifier_ifrit_overheat_fire_debuff", "heroes/ifrit/ifrit_overheat.lua", LUA_MODIFIER_MOTION_NONE )
modifier_ifrit_overheat_fire_debuff = class({})

function modifier_ifrit_overheat_fire_debuff:OnCreated(kv)
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("dot_damage")
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_ifrit_overheat_fire_debuff:OnRefresh(kv)
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("dot_damage")
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
end

function modifier_ifrit_overheat_fire_debuff:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_overheat_fire_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_overheat_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_overheat_fire_debuff:IsFireDebuff()
	return true
end