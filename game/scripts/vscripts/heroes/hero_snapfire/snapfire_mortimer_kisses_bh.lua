snapfire_mortimer_kisses_bh = class({})
LinkLuaModifier("modifier_snapfire_mortimer_kisses_bh_buff", "heroes/hero_snapfire/snapfire_mortimer_kisses_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_mortimer_kisses_bh_targeting", "heroes/hero_snapfire/snapfire_mortimer_kisses_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_mortimer_kisses_bh_fire", "heroes/hero_snapfire/snapfire_mortimer_kisses_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_mortimer_kisses_bh_fire_damage", "heroes/hero_snapfire/snapfire_mortimer_kisses_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_mortimer_kisses_bh_talent", "heroes/hero_snapfire/snapfire_mortimer_kisses_bh", LUA_MODIFIER_MOTION_NONE)

function snapfire_mortimer_kisses_bh:IsStealable()
	return true
end

function snapfire_mortimer_kisses_bh:IsHiddenWhenStolen()
	return false
end

function snapfire_mortimer_kisses_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration = self:GetTalentSpecialValueFor("duration_tooltip")

	caster:AddNewModifier(caster, self, "modifier_snapfire_mortimer_kisses_bh_buff", {Duration = duration})

	if caster:HasTalent("special_bonus_unique_snapfire_mortimer_kisses_bh_2") then
		caster:AddNewModifier(caster, self, "modifier_snapfire_mortimer_kisses_bh_talent", {Duration = duration})
	end
end

function snapfire_mortimer_kisses_bh:OnProjectileHit(hTarget, vLocation)
	if hTarget then
		self:CreateFirePit(vLocation)

		hTarget:ForceKill(false)
	end
end

function snapfire_mortimer_kisses_bh:CreateFirePit(vLocation)
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("burn_ground_duration")
	local radius = self:GetTalentSpecialValueFor("impact_radius")
	local damage = self:GetTalentSpecialValueFor("damage_per_impact")

	EmitSoundOnLocationWithCaster(vLocation, "Hero_Snapfire.MortimerBlob.Impact", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced_explosion.vpcf", PATTACH_POINT, caster, {[3]=vLocation})
	ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf", PATTACH_POINT, caster, {[3]=vLocation})

	local enemies = caster:FindEnemyUnitsInRadius(vLocation, radius, {})
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end

	CutTreesInRadius(vLocation, radius)

	CreateModifierThinker(caster, self, "modifier_snapfire_mortimer_kisses_bh_fire", {Duration = duration}, vLocation, caster:GetTeam(), false)
end

modifier_snapfire_mortimer_kisses_bh_buff = class({})

function modifier_snapfire_mortimer_kisses_bh_buff:OnCreated(table)
    if IsServer() then 
        local parent = self:GetParent()

        self.projectile_count = self:GetTalentSpecialValueFor("projectile_count")
        self.duration_tooltip = self:GetTalentSpecialValueFor("duration_tooltip")

        self.projectile_speed = self:GetTalentSpecialValueFor("projectile_speed")
		self.impact_radius = self:GetTalentSpecialValueFor("impact_radius")
		self.projectile_vision = self:GetTalentSpecialValueFor("projectile_vision")

		self.min_range = self:GetTalentSpecialValueFor("min_range")

		self.turn_rate = self:GetTalentSpecialValueFor("turn_rate")

		self.mousePos = parent:GetCursorPosition()

		self.animationTranslator = ""

		if parent:HasTalent("special_bonus_unique_snapfire_mortimer_kisses_bh_1") then
			self.animationTranslator = "fast_launches"
		end

        self:StartIntervalThink(0)
    end
end

function modifier_snapfire_mortimer_kisses_bh_buff:OnRefresh(table)
    if IsServer() then 
        local parent = self:GetParent()

        self.projectile_count = self:GetTalentSpecialValueFor("projectile_count")
        self.duration_tooltip = self:GetTalentSpecialValueFor("duration_tooltip")

        self.projectile_speed = self:GetTalentSpecialValueFor("projectile_speed")
		self.impact_radius = self:GetTalentSpecialValueFor("impact_radius")
		self.projectile_vision = self:GetTalentSpecialValueFor("projectile_vision")

		self.min_range = self:GetTalentSpecialValueFor("min_range")

		self.mousePos = parent:GetCursorPosition()

        self:StartIntervalThink(0)
    end
end

function modifier_snapfire_mortimer_kisses_bh_buff:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		local minimumDistance = self.min_range
		if not parent:IsRooted() then minimumDistance = self.impact_radius end
		local distance = math.min( self:GetAbility():GetTrueCastRange(), math.max( CalculateDistance( self.mousePos, parent ), minimumDistance ) )
		print( distance )
		self.mousePos = parent:GetAbsOrigin() + CalculateDirection( self.mousePos, parent ) * distance
		
		local duration = distance/self.projectile_speed

		local dummy = ability:CreateDummy(self.mousePos, duration)

		parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)

		CreateModifierThinker(parent, ability, "modifier_snapfire_mortimer_kisses_bh_targeting", {Duration = duration}, self.mousePos, parent:GetTeam(), false)

		EmitSoundOn("Hero_Snapfire.MortimerGrunt", parent)
		EmitSoundOn("Hero_Snapfire.MortimerBlob.Launch", parent)
		EmitSoundOn("Hero_Snapfire.MortimerBlob.Projectile", parent)
		ability:FireTrackingProjectile("particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf", dummy, self.projectile_speed, {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, self.projectile_vision)
		
		self:StartIntervalThink(self.duration_tooltip/self.projectile_count)
	end
end

function modifier_snapfire_mortimer_kisses_bh_buff:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()

		parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
		parent:Stop()
	end
end

function modifier_snapfire_mortimer_kisses_bh_buff:CheckState()
	return { [MODIFIER_STATE_ROOTED] = true,
			 [MODIFIER_STATE_DISARMED] = true }
end

function modifier_snapfire_mortimer_kisses_bh_buff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_TURN_RATE_OVERRIDE,
					MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
					MODIFIER_EVENT_ON_ORDER,
					MODIFIER_EVENT_ON_ATTACK_RECORD,
					MODIFIER_EVENT_ON_ABILITY_EXECUTED,
					MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
    return funcs
end

function modifier_snapfire_mortimer_kisses_bh_buff:GetActivityTranslationModifiers()
	return self.animationTranslator
end

function modifier_snapfire_mortimer_kisses_bh_buff:OnAbilityExecuted(params)
	if IsServer() then
		local parent = self:GetParent()
		local unit = params.unit
		local ability = params.ability

		if unit == parent and ability ~= self:GetAbility() then
			self:Destroy()
		end
	end
end

function modifier_snapfire_mortimer_kisses_bh_buff:OnOrder(params)
    if IsServer() then 
        local parent = self:GetParent()
        local unit = params.unit
        local order = params.order_type

        if parent == unit then
        	if ( order == DOTA_UNIT_ORDER_HOLD_POSITION or order == DOTA_UNIT_ORDER_STOP ) and unit:IsRooted() then
        		self:Destroy()
        	elseif order == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order == DOTA_UNIT_ORDER_MOVE_TO_TARGET
        		 or order == DOTA_UNIT_ORDER_ATTACK_MOVE or order == DOTA_UNIT_ORDER_ATTACK_TARGET
        		 or order == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION or order == DOTA_UNIT_ORDER_CAST_POSITION then
        		 
        		 --if CalculateDistance(self.mousePos, parent:GetAbsOrigin()) >= self.min_range then
        		 	self.mousePos = params.new_pos--ClientServer:RequestMousePosition( parent:GetPlayerID() )
        		 --end

        		 if params.target then
        		 	self.mousePos = params.target:GetAbsOrigin()
        		 end
        	end
        end
    end
end

function modifier_snapfire_mortimer_kisses_bh_buff:OnAttackRecord(params)
	if IsServer() then
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if target ~= attacker and parent == attacker then
			self.mousePos = target:GetAbsOrigin()
		end
	end
end

function modifier_snapfire_mortimer_kisses_bh_buff:GetModifierTurnRate_Override()
    return self.turn_rate
end

function modifier_snapfire_mortimer_kisses_bh_buff:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_snapfire_mortimer_kisses_bh_buff:IsPurgable()
    return true
end

function modifier_snapfire_mortimer_kisses_bh_buff:IsDebuff()
    return false
end

modifier_snapfire_mortimer_kisses_bh_targeting = class({})

function modifier_snapfire_mortimer_kisses_bh_targeting:OnCreated(table)
    if IsServer() then 
        local parent = self:GetParent()
        local caster = self:GetCaster()

        local radius = self:GetTalentSpecialValueFor("impact_radius")

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf", PATTACH_POINT, caster)
        			ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
        			ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 0, 0))
        			ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetRemainingTime(), 0, 0))
        self:AttachEffect(nfx)
    end
end

modifier_snapfire_mortimer_kisses_bh_fire = class({})

function modifier_snapfire_mortimer_kisses_bh_fire:OnCreated(table)
    if IsServer() then 
        local parent = self:GetParent()
        local caster = self:GetCaster()

        self.radius = self:GetTalentSpecialValueFor("impact_radius")
        self.burn_linger_duration = self:GetTalentSpecialValueFor("burn_linger_duration")

        EmitSoundOn("Hero_Snapfire.MortimerBlob.Magma", parent)

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf", PATTACH_POINT, caster)
        			ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
        			ParticleManager:SetParticleControl(nfx, 2, Vector( self.radius, self.radius, self.radius ) )
        self:AttachEffect(nfx)
    end
end

function modifier_snapfire_mortimer_kisses_bh_fire:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Snapfire.MortimerBlob.Magma", self:GetParent())
	end
end

function modifier_snapfire_mortimer_kisses_bh_fire:IsAura()
	return true
end

function modifier_snapfire_mortimer_kisses_bh_fire:GetAuraRadius()
	return self.radius
end

function modifier_snapfire_mortimer_kisses_bh_fire:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_snapfire_mortimer_kisses_bh_fire:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_snapfire_mortimer_kisses_bh_fire:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_snapfire_mortimer_kisses_bh_fire:GetAuraDuration()
	return self.burn_linger_duration
end

function modifier_snapfire_mortimer_kisses_bh_fire:GetModifierAura()
	return "modifier_snapfire_mortimer_kisses_bh_fire_damage"
end

modifier_snapfire_mortimer_kisses_bh_fire_damage = class({})

function modifier_snapfire_mortimer_kisses_bh_fire_damage:OnCreated(table)
	self.slow_ms = -self:GetTalentSpecialValueFor("move_slow_pct")

    if IsServer() then 
        local parent = self:GetParent()
        local caster = self:GetCaster()

        self.burn_rate = self:GetTalentSpecialValueFor("burn_interval")
        self.damage = self:GetTalentSpecialValueFor("burn_damage") * self.burn_rate

        EmitSoundOn("Hero_Snapfire.MortimerBlob.Target", parent)

        self:StartIntervalThink(self.burn_rate)
    end
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:OnRefresh(table)
    if IsServer() then 
        self:StartIntervalThink(self.burn_rate)
    end
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:OnRemoved()
    if IsServer() then 
        StopSoundOn("Hero_Snapfire.MortimerBlob.Target", self:GetParent())
    end
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    ability:DealDamage(caster, parent, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return funcs
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:GetModifierMoveSpeedBonus_Percentage()
    return self.slow_ms
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:IsPurgable()
    return false
end

function modifier_snapfire_mortimer_kisses_bh_fire_damage:IsDebuff()
    return true
end

modifier_snapfire_mortimer_kisses_bh_talent = class({})

function modifier_snapfire_mortimer_kisses_bh_talent:OnCreated(table)
    self.damage_reduction = self:GetCaster():FindTalentValue("")
end

function modifier_snapfire_mortimer_kisses_bh_talent:OnRefresh(table)
    self.damage_reduction = self:GetCaster():FindTalentValue("")
end

function modifier_snapfire_mortimer_kisses_bh_talent:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
    return funcs
end

function modifier_snapfire_mortimer_kisses_bh_talent:GetModifierIncomingDamage_Percentage()
	return self.damage_reduction
end

function modifier_snapfire_mortimer_kisses_bh_buff:IsPurgable()
    return true
end

function modifier_snapfire_mortimer_kisses_bh_buff:IsDebuff()
    return false
end