winterw_arctic_sting = class({})
LinkLuaModifier( "modifier_arctic_sting", "heroes/hero_ww/winterw_arctic_sting.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arctic_sting_target", "heroes/hero_ww/winterw_arctic_sting.lua" ,LUA_MODIFIER_MOTION_NONE )

function winterw_arctic_sting:IsStealable()
    return true
end

function winterw_arctic_sting:IsHiddenWhenStolen()
    return false
end

function winterw_arctic_sting:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    if self:GetCaster():HasScepter() then
        return behavior + DOTA_ABILITY_BEHAVIOR_TOGGLE
    end
    return behavior
end

function winterw_arctic_sting:GetCooldown( iLvl )
	if self:GetCaster():HasScepter() then
		return 0
	else
		return self.BaseClass.GetCooldown( self, iLvl )
	end
end

function winterw_arctic_sting:OnToggle()
    local caster = self:GetCaster()
    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_arctic_sting", {})
    else
        caster:RemoveModifierByName("modifier_arctic_sting")
    end
end

function winterw_arctic_sting:OnInventoryContentsChanged()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName("modifier_arctic_sting")
    if caster:HasScepter() and modifier and modifier:GetDuration() ~= -1 then
        caster:RemoveModifierByName("modifier_arctic_sting")
        caster:AddNewModifier(caster, self, "modifier_arctic_sting", {})
        self:ToggleAbility()
    elseif not caster:HasScepter() and modifier and modifier:GetDuration() == -1 then
        caster:RemoveModifierByName("modifier_arctic_sting")
        self:ToggleAbility()
        caster:AddNewModifier(caster, self, "modifier_arctic_sting",  {Duration = self:GetTalentSpecialValueFor("duration")})
        
    end
end

function winterw_arctic_sting:OnSpellStart()
    local caster = self:GetCaster()
    EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.Cast", caster)
    caster:AddNewModifier(caster, self, "modifier_arctic_sting", {Duration = self:GetTalentSpecialValueFor("duration")})
end

function winterw_arctic_sting:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_arctic_sting", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_arctic_sting = ({})
function modifier_arctic_sting:OnCreated(table)
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_winterw_arctic_sting_1")
	self.talent1Cleave = self:GetCaster():FindTalentValue("special_bonus_unique_winterw_arctic_sting_1")
	self.scepter_cost = self:GetTalentSpecialValueFor("mana_cost_scepter")
	self.attack_range = self:GetTalentSpecialValueFor("attack_range_bonus")
	self.vision = self:GetTalentSpecialValueFor("night_vision_bonus")
	self.projectile_speed = self:GetTalentSpecialValueFor("projectile_speed_bonus")
	self.duration = self:GetTalentSpecialValueFor("burn_duration")
	if self.talent1 then
		self:GetParent():HookInModifier("GetModifierAreaDamage", self )
	end
    if IsServer() then
        local startFX = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(startFX, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(startFX)

        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_flying.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_wing_l", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_wing_r", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nfx, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eye_l", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nfx, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eye_r", self:GetCaster():GetAbsOrigin(), true)

        self:GetCaster():SetProjectileModel("particles/units/heroes/hero_winter_wyvern/winter_wyvern_arctic_attack.vpcf")
        self:StartIntervalThink(1.0)
    end
end

function modifier_arctic_sting:OnIntervalThink()
    if self:GetCaster():HasScepter() and self:GetAbility():GetToggleState() then
		if self:GetAbility():SpendMana( self.scepter_cost ) then
		else
			self:GetAbility():ToggleAbility()
		end
    end
end

function modifier_arctic_sting:OnRemoved()
    if IsServer() then
        local startFX = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(startFX, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(startFX)

        self:GetCaster():RevertProjectile()
        GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(), 250, true)
        ParticleManager:DestroyParticle(self.nfx, false)
    end
	if self.talent1 then
		self:GetParent():HookOutModifier("GetModifierAreaDamage", self )
	end
end

function modifier_arctic_sting:CheckState()
    local state = { [MODIFIER_STATE_FLYING] = true}
    return state
end

function modifier_arctic_sting:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK
    }

    return funcs
end

function modifier_arctic_sting:GetModifierAttackRangeBonus()
    return self.attack_range
end

function modifier_arctic_sting:GetModifierAreaDamage()
    return self.talent1Cleave * 2
end

function modifier_arctic_sting:GetBonusNightVision()
    return self.vision
end

function modifier_arctic_sting:GetModifierProjectileSpeedBonus()
    return self.projectile_speed
end

function modifier_arctic_sting:OnAttack(params)
    -- if params.attacker == self:GetCaster() and params.target:IsAlive() and self.talent1 then
        -- if not self.preventInfiniteLoopingLmao then
			-- self.preventInfiniteLoopingLmao = true
			-- for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.talent1Radius) ) do
				-- params.attacker:PerformGenericAttack( enemy )
			-- end
			-- self.preventInfiniteLoopingLmao = false
		-- end
    -- end
end

function modifier_arctic_sting:OnAttackLanded(params)
    if params.attacker == self:GetCaster() and params.target:IsAlive() then
        if self:GetCaster():HasScepter() then
            EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.projectileImpact", params.target)
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_arctic_sting_target", {Duration = self.duration})
        else
            if not params.target:HasModifier("modifier_arctic_sting_target") then
                EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.projectileImpact", params.target)
                params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_arctic_sting_target", {Duration = self.duration})
            end
        end
		if self.talent1 then
			for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), 325) ) do
				if enemy ~= params.target then
					if self:GetCaster():HasScepter() or not enemy:HasModifier("modifier_arctic_sting_target") then
						EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.projectileImpact", enemy)
						enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_arctic_sting_target", {Duration = self.duration})
					end
				end
			end
		end
    end
end

function modifier_arctic_sting:IsDebuff()
    return false
end

function modifier_arctic_sting:IsPurgable()
	return not self:GetCaster():HasScepter()
end

function modifier_arctic_sting:GetEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_buff.vpcf"
end

function modifier_arctic_sting:GetStatusEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_hero_effect.vpcf"
end

function modifier_arctic_sting:StatusEffectPriority()
    return 13
end

modifier_arctic_sting_target = ({})
function modifier_arctic_sting_target:OnCreated(table)
	self.damage_pct = self:GetTalentSpecialValueFor("burn_curr_hp")/100
	self.damage_base = self:GetTalentSpecialValueFor("burn_damage")
	self.slow = self:GetTalentSpecialValueFor("move_slow")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_winterw_arctic_sting_2")
	self.talent2Chill = self.damage_base * self:GetCaster():FindTalentValue("special_bonus_unique_winterw_arctic_sting_2") / 100
    if IsServer() then
		self:OnIntervalThink()
        self:StartIntervalThink(1.0)
    end
end

function modifier_arctic_sting_target:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
    local currentHealth = parent:GetHealth()
    local damage = self.damage_base * caster:GetSpellAmplification( false ) + currentHealth * self.damage_pct
    ability:DealDamage(caster, parent, damage, {damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	if self.talent2 then
		parent:AddChill( ability, caster, self:GetRemainingTime(), math.floor(self.talent2Chill + 0.5) )
	end
end

function modifier_arctic_sting_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_arctic_sting_target:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_arctic_sting_target:IsDebuff()
    return true
end

function modifier_arctic_sting_target:GetEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end

function modifier_arctic_sting_target:GetStatusEffectName()
    return "particles/status_fx/status_effect_wyvern_arctic_burn.vpcf"
end

function modifier_arctic_sting_target:StatusEffectPriority()
    return 14
end