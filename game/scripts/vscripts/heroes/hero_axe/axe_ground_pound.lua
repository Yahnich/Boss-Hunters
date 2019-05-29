axe_ground_pound = class({})
LinkLuaModifier( "modifier_ground_pound_aura", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ground_pound", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ground_pound_damage_reduction", "heroes/hero_axe/axe_ground_pound.lua" ,LUA_MODIFIER_MOTION_NONE )
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


	local radius = self:GetTalentSpecialValueFor("radius")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {})
	local duration = self:GetTalentSpecialValueFor("duration")
	local kill_threshold = ( caster:GetStrength() * self:GetTalentSpecialValueFor("kill_threshold") )
	local damage = caster:GetStrength() * self:GetTalentSpecialValueFor("damage")
	local think = CreateModifierThinker(caster, self, "modifier_ground_pound_aura", {Duration = duration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	local dunkSuccess = false
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if not enemy:IsTaunted() then
				enemy:ApplyKnockBack(caster:GetAbsOrigin(), 0.75, 0.5, 0, 100, caster, self)
			else
				enemy:Daze(self, caster, self:GetTalentSpecialValueFor("daze_duration"))
			end
			if enemy:GetHealth() <= kill_threshold then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx,4, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)

				enemy:AttemptKill(self, caster)
				dunkSuccess = true
				
				local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx2, 1, caster:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx2)

				self:EndCooldown()
			else
				ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_POINT_FOLLOW, enemy)
				EmitSoundOn("Hero_Axe.Culling_Blade_Fail", enemy)
				self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
	else
		EmitSoundOn("Hero_Axe.Culling_Blade_Fail", self:GetCaster())
	end
	if dunkSuccess then
		EmitSoundOn("Hero_Axe.Culling_Blade_Success", self:GetCaster())
		if caster:HasTalent("special_bonus_unique_axe_ground_pound_1") then
			caster:AddNewModifier(caster, self, "modifier_ground_pound_damage_reduction", {Duration = caster:FindTalentValue("special_bonus_unique_axe_ground_pound_1", "duration")})
		end
		if caster:HasTalent("special_bonus_unique_axe_ground_pound_1_2") then
			local enemies2 = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {})
			for _,enemy2 in pairs(enemies2) do
				enemy2:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = caster:FindAbilityByName("axe_blood_hunger"):GetTalentSpecialValueFor("duration")})
			end
		end
	else
		if caster:HasTalent("special_bonus_unique_axe_ground_pound_1") then
			caster:AddNewModifier(caster, self, "modifier_ground_pound_damage_reduction", {Duration = caster:FindTalentValue("special_bonus_unique_axe_ground_pound_1", "duration") / 2})
		end
	end
end

modifier_ground_pound_aura = class({})

function modifier_ground_pound_aura:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
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
function modifier_ground_pound:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_ground_pound:GetModifierMoveSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("move_slow")
end

function modifier_ground_pound:IsDebuff()
	return true
end

modifier_ground_pound_damage_reduction = class({})
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