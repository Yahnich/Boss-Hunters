axe_ground_pound = class({})
LinkLuaModifier( "modifier_blood_hunger", "heroes/hero_axe/axe_blood_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function axe_ground_pound:PiercesDisableResistance()
    return true
end

function axe_ground_pound:IsStealable()
	return true
end

function axe_ground_pound:IsHiddenWhenStolen()
	return false
end

function axe_ground_pound:OnSpellStart()
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {})
	local duration = self:GetSpecialValueFor("duration")
	local buffDur = self:GetSpecialValueFor("buff_duration")
	local tauntDuration = self:GetSpecialValueFor("taunt_duration")
	local damage = caster:GetStrength() * self:GetSpecialValueFor("damage")
	
	local think = CreateModifierThinker(caster, self, "modifier_ground_pound_aura", {Duration = duration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	local dunkSuccess = false
	
	if caster:HasTalent("special_bonus_unique_axe_ground_pound_2") then
		local bloodhunger = caster:FindAbilityByName("axe_blood_hunger")
		local enemies2 = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {})
		for _,enemy2 in pairs(enemies2) do
			enemy2:AddNewModifier(caster, bloodhunger, "modifier_blood_hunger", {Duration = bloodhunger:GetSpecialValueFor("duration")})
		end
	end
	
	if #enemies > 0 then
		caster:AddNewModifier(caster, self, "modifier_ground_pound_critical", {duration = 1})
		caster:RemoveModifierByName("modifier_ground_pound_damage")
		caster:AddNewModifier(caster, self, "modifier_ground_pound_damage", {duration = buffDur})
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:Daze(self, caster, tauntDuration)
				caster:PerformAbilityAttack(enemy, true, self, false, false, true)
				enemy:Taunt(self, caster, tauntDuration)
				ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_POINT, caster, {[4] = enemy:GetAbsOrigin()})
				if not enemy:IsAlive() or enemy:GetHealth() <= 0 then
					dunkSuccess = true
					ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = "attach_hitloc", [1] = caster:GetAbsOrigin()})
				end
			end
		end
		caster:RemoveModifierByName("modifier_ground_pound_critical")
	else
		EmitSoundOn("Hero_Axe.Culling_Blade_Fail", self:GetCaster())
	end
	if dunkSuccess then
		self:EndCooldown()
		EmitSoundOn("Hero_Axe.Culling_Blade_Success", self:GetCaster())
	else
		EmitSoundOn("Hero_Axe.Culling_Blade_Fail", self:GetCaster())
	end
	if caster:HasTalent("special_bonus_unique_axe_ground_pound_1") then
		local duration = caster:FindTalentValue("special_bonus_unique_axe_ground_pound_1", "duration")
		if not dunkSuccess then
			duration = duration / 2
		end
		caster:AddNewModifier(caster, self, "modifier_ground_pound_damage_reduction", {Duration = duration})
	end
end


modifier_ground_pound_critical = class({})
LinkLuaModifier( "modifier_ground_pound_critical", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_ground_pound_critical:OnCreated()
	self.crit = self:GetSpecialValueFor("critical_damage")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_ground_pound_critical:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_ground_pound_critical:GetModifierCriticalDamage()
	return self.crit
end

function modifier_ground_pound_critical:IsDebuff()
	return false
end


modifier_ground_pound_damage = class({})
LinkLuaModifier( "modifier_ground_pound_damage", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_ground_pound_damage:OnCreated()
	self:OnRefresh()
end

function modifier_ground_pound_damage:OnRefresh()
	self.damage = math.max( 0, self:GetSpecialValueFor("armor_damage") * self:GetParent():GetPhysicalArmorValue(false) )
	if self.damage == 0 then
		self:Destroy()
	end
end

function modifier_ground_pound_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_ground_pound_damage:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_ground_pound_damage:IsDebuff()
	return false
end

modifier_ground_pound_aura = class({})
LinkLuaModifier( "modifier_ground_pound_aura", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_ground_pound_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_ground_pound_aura:IsAura()
	return true
end

function modifier_ground_pound_aura:GetAuraDuration()
	return 1.0
end

function modifier_ground_pound_aura:GetAuraRadius()
	return self.radius
end

function modifier_ground_pound_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_ground_pound_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ground_pound_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_ground_pound_aura:GetModifierAura()
	return "modifier_ground_pound"
end

function modifier_ground_pound_aura:GetEffectName()
	return "particles/axe_groundpound/axe_ground_pound_base2.vpcf"
end

modifier_ground_pound = class({})
LinkLuaModifier( "modifier_ground_pound", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_ground_pound:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_ground_pound:GetModifierMoveSpeedBonus_Constant()
	return self:GetSpecialValueFor("move_slow")
end

function modifier_ground_pound:IsDebuff()
	return true
end

modifier_ground_pound_damage_reduction = class({})
LinkLuaModifier( "modifier_ground_pound_damage_reduction", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_ground_pound_damage_reduction:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_ground_pound_damage_reduction:GetModifierIncomingDamage_Percentage()
	return self:GetCaster():FindTalentValue("special_bonus_unique_axe_ground_pound_1")
end

function modifier_ground_pound_damage_reduction:IsDebuff()
	return false
end