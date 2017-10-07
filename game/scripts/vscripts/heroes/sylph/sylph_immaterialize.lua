sylph_immaterialize = sylph_immaterialize or class({})

function sylph_immaterialize:OnSpellStart()
	EmitSoundOn("Ability.PowershotPull.Stinger", self:GetCaster())
	local windbuff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_immaterialize_buff", {duration = self:GetSpecialValueFor("duration")})
end

LinkLuaModifier( "modifier_sylph_immaterialize_buff", "heroes/sylph/sylph_immaterialize.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_immaterialize_buff = modifier_sylph_immaterialize_buff or class({})

function modifier_sylph_immaterialize_buff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
	if IsServer() then
		self:StartIntervalThink(0)
		self:GetAbility():StartDelayedCooldown() 
	end
end

function modifier_sylph_immaterialize_buff:OnRefresh()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end


function modifier_sylph_immaterialize_buff:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_sylph_immaterialize_buff:OnIntervalThink()
	ProjectileManager:ProjectileDodge(self:GetCaster())
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _, enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_sylph_immaterialize_talent_slow") then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sylph_immaterialize_talent_slow", {duration = 0.5})
		else
			enemy:FindModifierByName("modifier_sylph_immaterialize_talent_slow"):SetDuration(0.5, true)
		end
	end
end

function modifier_sylph_immaterialize_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_sylph_immaterialize_buff:GetModifierIncomingDamage_Percentage(params)
	return self.evasion
end

function modifier_sylph_immaterialize_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_sylph_immaterialize_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_immaterialize.vpcf"
end

function modifier_sylph_immaterialize_buff:IsAura()
	return self:GetParent():HasTalent("sylph_immaterialize_talent_1")
end

function modifier_sylph_immaterialize_buff:GetAuraEntityReject( entity )
	if IsServer() then
		return self:GetParent() == entity
	end
end

--------------------------------------------------------------------------------

function modifier_sylph_immaterialize_buff:GetModifierAura()
	if self:GetParent():HasTalent("sylph_immaterialize_talent_1") then
		return "modifier_sylph_immaterialize_buff"
	end
end

--------------------------------------------------------------------------------

function modifier_sylph_immaterialize_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_sylph_immaterialize_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_sylph_immaterialize_buff:GetAuraRadius()
	return self:GetParent():GetIdealSpeed() * self:GetParent():FindTalentValue("sylph_immaterialize_talent_1")
end

--------------------------------------------------------------------------------
function modifier_sylph_immaterialize_buff:IsPurgable()
    return false
end


LinkLuaModifier( "modifier_sylph_immaterialize_talent_slow", "heroes/sylph/sylph_immaterialize.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_immaterialize_talent_slow = modifier_sylph_immaterialize_talent_slow or class({})

function modifier_sylph_immaterialize_talent_slow:OnCreated()
	self.speed = self:GetAbility():GetSpecialValueFor("move_slow")
end


function modifier_sylph_immaterialize_talent_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_sylph_immaterialize_talent_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

function modifier_sylph_immaterialize_talent_slow:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

LinkLuaModifier( "modifier_sylph_immaterialize_talent_1", "heroes/sylph/sylph_immaterialize.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_immaterialize_talent_1 = modifier_sylph_immaterialize_talent_1 or class({})

function modifier_sylph_immaterialize_talent_1:IsHidden()
	return true
end

function modifier_sylph_immaterialize_talent_1:RemoveOnDeath()
	return false
end