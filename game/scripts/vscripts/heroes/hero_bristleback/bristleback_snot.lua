bristleback_snot = class({})
LinkLuaModifier( "modifier_snot", "heroes/hero_bristleback/bristleback_snot.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bristleback_snot_autocast", "heroes/hero_bristleback/bristleback_snot.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_snot:GetIntrinsicModifierName()
	return "modifier_bristleback_snot_autocast"
end

function bristleback_snot:IsStealable()
	return true
end

function bristleback_snot:IsHiddenWhenStolen()
	return false
end

function bristleback_snot:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
end

function bristleback_snot:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
end

function bristleback_snot:GetCastPoint()
	if self:GetCaster():HasScepter() then
		return 0
	else
		return 0.3
	end
end

function bristleback_snot:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Bristleback.ViscousGoo.Cast", caster)
	
	if caster:HasScepter() then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("scepter_radius"), {})
		for _,enemy in pairs(enemies) do
			self:FireSnot(enemy)
		end
	elseif self:GetCursorTarget() then
		self:FireSnot( self:GetCursorTarget() )
	else
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange(), {})
		for _,enemy in pairs(enemies) do
			self:FireSnot(enemy)
			break
		end
	end
	
end

function bristleback_snot:FireSnot(target, hSource)
	local caster = self:GetCaster()	
	local source = hSource or caster
	local info = 
	{
		Target = target,
		Source = source,
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
	if hTarget ~= nil and hTarget:IsAlive() and not hTarget:TriggerSpellAbsorb( self ) then
		local duration = TernaryOperator( self:GetTalentSpecialValueFor("minion_duration"), hTarget:IsMinion(), self:GetTalentSpecialValueFor("goo_duration") )
		EmitSoundOn("Hero_Bristleback.ViscousGoo.Target", hTarget)
		local snot = hTarget:AddNewModifier(self:GetCaster(), self, "modifier_snot", {Duration = duration})
		if snot then
			local stacks = math.min( self:GetTalentSpecialValueFor("stack_limit"), snot:GetStackCount() + 1 )
		end
	end
end

modifier_bristleback_snot_autocast = class({})

if IsServer() then
	function modifier_bristleback_snot_autocast:OnCreated()
		self:StartIntervalThink(0.1)
	end
	
	function modifier_bristleback_snot_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if ability:IsFullyCastable() 
		and ability:GetAutoCastState() 
		and caster:IsAlive() 
		and caster:IsRealHero()
		and ability:GetManaCost(-1) <= caster:GetMana() 
		and not caster:HasActiveAbility() then
			ability:CastSpell()
		elseif not ability:IsOwnersManaEnough() then
			ability:ToggleAutoCast()
		end
	end
end

function modifier_bristleback_snot_autocast:IsHidden() return true end

modifier_snot = class({})
function modifier_snot:OnCreated()
	self:OnRefresh()
end

function modifier_snot:OnRefresh()
	self.base_slow = self:GetTalentSpecialValueFor("base_move_slow")
	self.slow_per_stack = self:GetTalentSpecialValueFor("move_slow_per_stack")
	self.base_armor = self:GetTalentSpecialValueFor("base_armor")
	self.armor_per_stack = self:GetTalentSpecialValueFor("armor_per_stack")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_snot_2")
	if IsServer() then self:SetStackCount( math.min( self:GetStackCount() + 1, self:GetTalentSpecialValueFor("stack_limit")) ) end
end

function modifier_snot:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_snot:GetModifierMoveSpeedBonus_Percentage()
    return self.base_slow + self.slow_per_stack * self:GetStackCount()
end

function modifier_snot:GetModifierPhysicalArmorBonus()
    return self.base_armor + self.armor_per_stack * self:GetStackCount()
end

function modifier_snot:GetModifierAttackSpeedBonus_Constant()
    return self.as * self:GetStackCount()
end

function modifier_snot:IsDebuff()
    return true
end

function modifier_snot:GetEffectName()
    return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end