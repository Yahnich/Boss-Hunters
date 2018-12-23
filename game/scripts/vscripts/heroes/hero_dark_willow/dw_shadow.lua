	dw_shadow = class({})
LinkLuaModifier("modifier_dw_shadow", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_shadow_damage", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_shadow_talent", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_shadow_bonus_as", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)

function dw_shadow:IsStealable()
    return true
end

function dw_shadow:IsHiddenWhenStolen()
    return false
end

function dw_shadow:GetManaCost( iLvl )
	if self:GetCaster():HasModifier("modifier_dw_shadow") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function dw_shadow:OnSpellStart()
	local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_dw_shadow_damage")

	if caster:HasModifier("modifier_dw_shadow") then
		caster:RemoveModifierByName("modifier_dw_shadow")
	else
		EmitSoundOn("Hero_DarkWillow.Shadow_Realm", caster)

		caster:AddNewModifier(caster, self, "modifier_dw_shadow", {Duration = self:GetTalentSpecialValueFor("duration")})
		self:EndCooldown()
	end
end

function dw_shadow:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	local damage = self.damage

	if hTarget then
		EmitSoundOn("Hero_DarkWillow.Shadow_Realm.Damage", attacker)
		
		self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

		-- if caster:HasTalent("special_bonus_unique_dw_shadow_1") then
			-- local ability = caster:FindAbilityByName("dw_bramble")
			-- ability:PlantBush(vLocation)
		-- end
	end
end

modifier_dw_shadow = class({})
function modifier_dw_shadow:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

    	ability.damage = 0
    	self.damage = self:GetTalentSpecialValueFor("damage") * FrameTime()

    	self.manaDrain = parent:GetMaxMana() * self:GetTalentSpecialValueFor("mana_drain")/100 * FrameTime()

    	if caster:HasTalent("special_bonus_unique_dw_shadow_2") then
    		ability.bonus_as = 0
    		self.bonus_as = caster:FindTalentValue("special_bonus_unique_dw_shadow_2") * FrameTime() / self:GetDuration()
    		self.Talent = true
    	end
		self.talent1 = caster:HasTalent("special_bonus_unique_dw_shadow_1")
    	self:StartIntervalThink(FrameTime())
    end
end

function modifier_dw_shadow:OnRefresh(table)
    if IsServer() then
    	self:GetAbility().damage = 0
    	self.damage = self:GetTalentSpecialValueFor("damage") * FrameTime()

    	self.manaDrain = self:GetParent():GetMaxMana() * self:GetTalentSpecialValueFor("mana_drain")/100 * FrameTime()
		self.talent1 = caster:HasTalent("special_bonus_unique_dw_shadow_1")
    	if caster:HasTalent("special_bonus_unique_dw_shadow_2") then
    		self:GetAbility().bonus_as = 0
    		self.bonus_as = caster:FindTalentValue("special_bonus_unique_dw_shadow_2") * FrameTime() / self:GetDuration()
    		self.Talent = true
    	end
    end
end

function modifier_dw_shadow:OnIntervalThink()
	self:GetParent():ReduceMana(self.manaDrain)
    self:GetAbility().damage = self:GetAbility().damage + self.damage

    if self.Talent then
    	self:GetAbility().bonus_as = self:GetAbility().bonus_as + self.bonus_as
    end
end

function modifier_dw_shadow:CheckState()
	return {[MODIFIER_STATE_UNSLOWABLE] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_ALLOW_PATHING_TROUGH_TREES] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_dw_shadow:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm.vpcf"
end

function modifier_dw_shadow:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf"
end

function modifier_dw_shadow:StatusEffectPriority()
	return 10
end

function modifier_dw_shadow:IsDebuff()
	return true
end

function modifier_dw_shadow:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		ability:SetCooldown()

		parent:AddNewModifier(caster, ability, "modifier_dw_shadow_damage", {})

		if caster:HasTalent("special_bonus_unique_dw_shadow_2") then
			parent:AddNewModifier(caster, ability, "modifier_dw_shadow_bonus_as", {Duration = 4})
		end
	end
end

function modifier_dw_shadow:IsAura()
	return self.talent1
end

function modifier_dw_shadow:GetModifierAura()
	return "modifier_dw_shadow_talent"
end

function modifier_dw_shadow:GetAuraRadius()
	return 900
end

function modifier_dw_shadow:GetAuraDuration()
	return 0.5
end

function modifier_dw_shadow:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_dw_shadow:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_dw_shadow:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_dw_shadow_talent = class({})
function modifier_dw_shadow_talent:OnCreated(kv)
	local caster = self:GetCaster()
	self.tick = caster:FindTalentValue("special_bonus_unique_dw_shadow_1", "tick")
    self.max_damage = self:GetTalentSpecialValueFor("duration") * self:GetTalentSpecialValueFor("damage") * caster:FindTalentValue("special_bonus_unique_dw_shadow_1", "damage") / 100
	self.max_slow = caster:FindTalentValue("special_bonus_unique_dw_shadow_1") * (-1)
	self.damage_growth = self.max_damage * self.tick / self:GetTalentSpecialValueFor("duration")
	self.slow_growth = self.max_slow * self.tick / self:GetTalentSpecialValueFor("duration")
	self.damage = self.damage_growth
	self.slow = self.slow_growth
	self:StartIntervalThink( self.tick )
end

function modifier_dw_shadow_talent:OnRefresh(kv)
	self:OnCreated(kv)
end

function modifier_dw_shadow_talent:OnIntervalThink()	
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if IsServer() then
		ability:DealDamage( caster, parent, self.damage )
		if self.damage < self.max_damage then
			self.damage = math.min( self.max_damage, self.damage + self.damage_growth )
		end
	end
	if self.slow > self.max_slow then
		self.slow = math.max( self.max_slow, self.slow + self.slow_growth )
	end
end

function modifier_dw_shadow_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_dw_shadow_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_dw_shadow_talent:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm_charge.vpcf"
end

function modifier_dw_shadow_talent:IsDebuff()
	return true
end

modifier_dw_shadow_damage = class({})
function modifier_dw_shadow_damage:OnCreated(table)
    self.bonus_ar = self:GetTalentSpecialValueFor("attack_range_bonus")
end

function modifier_dw_shadow_damage:OnRefresh(table)
    self.bonus_ar = self:GetTalentSpecialValueFor("attack_range_bonus")
end

function modifier_dw_shadow_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_EVENT_ON_ATTACK}
end

function modifier_dw_shadow_damage:GetModifierAttackRangeBonus()
	return self.bonus_ar
end

function modifier_dw_shadow_damage:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local target = params.target

		if attacker == caster and target ~= attacker then
			local distance = CalculateDistance(target, attacker)
			local speed = caster:GetProjectileSpeed()
			local time = distance/speed

			EmitSoundOn("Hero_DarkWillow.Shadow_Realm.Attack", attacker)

			self:GetAbility():FireTrackingProjectile("", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 250)

			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_shadow_attack.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 2, Vector(caster:GetProjectileSpeed(), 0, 0))
						--ParticleManager:SetParticleControlEnt(nfx, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 5, Vector(1, 0, 0))

			Timers:CreateTimer(time, function()
				ParticleManager:ClearParticle(nfx)
			end)

			self:Destroy()
		end
	end
end

function modifier_dw_shadow_damage:IsDebuff()
	return false
end

modifier_dw_shadow_bonus_as = class({})
function modifier_dw_shadow_bonus_as:OnCreated(table)
    self.bonus_as = self:GetAbility().bonus_as
end

function modifier_dw_shadow_bonus_as:OnRefresh(table)
    self.bonus_as = self:GetAbility().bonus_as
end

function modifier_dw_shadow_bonus_as:DeclareFunctions()
	return {}
end

function modifier_dw_shadow_bonus_as:GetModifierAttackSpeedBonus()
	return self.bonus_as
end

function modifier_dw_shadow_bonus_as:IsDebuff()
	return false
end