bristleback_snot = class({})
LinkLuaModifier( "modifier_snot", "heroes/hero_bristleback/bristleback_snot.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bristleback_snot_autocast", "heroes/hero_bristleback/bristleback_snot.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_snot:GetIntrinsicModifierName()
	return "modifier_bristleback_snot_autocast"
end

function bristleback_snot:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Bristleback.ViscousGoo.Cast", caster)

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		if caster:HasScepter() then
			self:FireSnot(enemy)
		else
			self:FireSnot(enemy)
			break
		end
	end
end

function bristleback_snot:FireSnot(target)
	local caster = self:GetCaster()	
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
	    iMoveSpeed = self:GetTalentSpecialValueFor("goo_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_3,
		bDrawsOnMinimap = false,                          -- Optional
        bDodgeable = true,                                -- Optional
        bIsAttack = false,                                -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bReplaceExisting = false,                         -- Optional
        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function bristleback_snot:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and hTarget:IsAlive() then
		EmitSoundOn("Hero_Bristleback.ViscousGoo.Target", hTarget)
		if hTarget:HasModifier("modifier_snot") then
			if hTarget:FindModifierByName("modifier_snot"):GetStackCount() <= self:GetTalentSpecialValueFor("stack_limit") then
				hTarget:AddNewModifier(self:GetCaster(), self, "modifier_snot", {Duration = self:GetTalentSpecialValueFor("goo_duration")}):IncrementStackCount()
			else
				hTarget:AddNewModifier(self:GetCaster(), self, "modifier_snot", {Duration = self:GetTalentSpecialValueFor("goo_duration")})
			end
		else
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_snot", {Duration = self:GetTalentSpecialValueFor("goo_duration")}):IncrementStackCount()
		end

		self:GetCaster():ModifyThreat(self:GetTalentSpecialValueFor("threat_gain"))
	end
end

modifier_bristleback_snot_autocast = class({})

if IsServer() then
	function modifier_bristleback_snot_autocast:OnCreated()
		self:StartIntervalThink(0.1)
	end
	
	function modifier_bristleback_snot_autocast:OnIntervalThink()
		if self:GetAbility():IsCooldownReady() and self:GetAbility():GetAutoCastState() and self:GetCaster():IsAlive() then
			self:GetAbility():CastSpell()
		end
	end
end

function modifier_bristleback_snot_autocast:IsHidden() return true end

modifier_snot = class({})

function modifier_snot:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_snot:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("move_slow_per_stack") * self:GetStackCount()
end

function modifier_snot:GetModifierPhysicalArmorBonus()
    return self:GetTalentSpecialValueFor("armor_per_stack") * self:GetStackCount()
end

function modifier_snot:IsDebuff()
    return true
end

function modifier_snot:GetEffectName()
    return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end