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
	return self.BaseClass.GetManaCost( self, iLvl )
end

function dw_shadow:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_dw_shadow", {Duration = self:GetTalentSpecialValueFor("duration")})
end

function dw_shadow:OnProjectileHitHandle(hTarget, vLocation, iProjectile)
	local caster = self:GetCaster()

	local damage = self.projectiles[iProjectile].damage

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

		self.max_damage = self:GetTalentSpecialValueFor("max_damage")
    	self.damage = 0
    	self.damageGrowth = self:GetTalentSpecialValueFor("max_damage") * 0.1 / self:GetTalentSpecialValueFor("max_delay")


    	-- self.manaDrain = parent:GetMaxMana() * self:GetTalentSpecialValueFor("mana_drain")/100 * FrameTime()

    	if caster:HasTalent("special_bonus_unique_dw_shadow_2") then
    		self.bonus_as = 0
    		self.bonus_asGrowth = caster:FindTalentValue("special_bonus_unique_dw_shadow_2") * 0.1 / self:GetDuration()
    		self.talent2 = true
    	end
		self.talent1 = caster:HasTalent("special_bonus_unique_dw_shadow_1")
    	self:StartIntervalThink(0.1)
    end
end

function modifier_dw_shadow:OnRefresh(table)
    if IsServer() then
    	self:GetAbility().damage = 0
    	self.damage = self:GetTalentSpecialValueFor("damage") * 0.1

    	-- self.manaDrain = self:GetParent():GetMaxMana() * self:GetTalentSpecialValueFor("mana_drain")/100 * FrameTime()
		self.talent1 = caster:HasTalent("special_bonus_unique_dw_shadow_1")
    	if caster:HasTalent("special_bonus_unique_dw_shadow_2") then
    		self.bonus_as = 0
    		self.bonus_asGrowth = caster:FindTalentValue("special_bonus_unique_dw_shadow_2") * 0.1 / self:GetDuration()
			self.talent2 = true
    	end
    end
end

function modifier_dw_shadow:OnIntervalThink()
	-- self:GetParent():ReduceMana(self.manaDrain)
    self.damage = math.min( self.max_damage, self.damage + self.damageGrowth )
	self:SetStackCount( math.floor(self.damage / self.max_damage * 100 + 0.5) )
    if self.talent2 then
    	self.bonus_as = self.bonus_as + self.bonus_asGrowth
    end
end

function modifier_dw_shadow:CheckState()
	return {[MODIFIER_STATE_UNSLOWABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_ALLOW_PATHING_TROUGH_TREES] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end


function modifier_dw_shadow:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_dw_shadow:OnAttackStart(params)
	if IsServer() then
		local caster = self:GetCaster()
		if caster == params.attacker then
			self:Destroy()
		end
	end
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

		parent:AddNewModifier(caster, ability, "modifier_dw_shadow_damage", {duration = self:GetTalentSpecialValueFor("linger_duration"), damage = self.damage})

		if caster:HasTalent("special_bonus_unique_dw_shadow_2") then
			parent:AddNewModifier(caster, ability, "modifier_dw_shadow_bonus_as", {Duration = caster:FindTalentValue("special_bonus_unique_dw_shadow_2", "duration"), attackspeed = self.bonus_as})
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
	return 400
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
    self.max_damage = self:GetTalentSpecialValueFor("max_damage") * caster:FindTalentValue("special_bonus_unique_dw_shadow_1", "damage") / 100
	self.max_slow = caster:FindTalentValue("special_bonus_unique_dw_shadow_1") * (-1)
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
		ability:DealDamage( caster, parent, self.tick * self.max_damage * caster:GetModifierStackCount( "modifier_dw_shadow", caster ) / 100 )
	end
end

function modifier_dw_shadow_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_dw_shadow_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.max_slow * self:GetCaster():GetModifierStackCount( "modifier_dw_shadow", self:GetCaster() ) / 100
end

function modifier_dw_shadow_talent:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm_charge.vpcf"
end

function modifier_dw_shadow_talent:IsDebuff()
	return true
end

modifier_dw_shadow_damage = class({})
function modifier_dw_shadow_damage:OnCreated(kv)
    self.bonus_ar = self:GetTalentSpecialValueFor("attack_range_bonus")
	self.damage = kv.damage
end

function modifier_dw_shadow_damage:OnRefresh(kv)
    self.bonus_ar = self:GetTalentSpecialValueFor("attack_range_bonus")
	self.damage = kv.damage
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
		local ability = self:GetAbility()
		local attacker = params.attacker
		local target = params.target

		if attacker == caster and target ~= attacker then
			local distance = CalculateDistance(target, attacker)
			local speed = caster:GetProjectileSpeed()
			local time = distance/speed

			EmitSoundOn("Hero_DarkWillow.Shadow_Realm.Attack", attacker)
			
			local projectile = ability:FireTrackingProjectile("", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 250)
			ability.projectiles = ability.projectiles or {}
			ability.projectiles[projectile] = {}
			ability.projectiles[projectile].damage = self.damage

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
function modifier_dw_shadow_bonus_as:OnCreated(kv)
    self.bonus_as = kv.attackspeed
end

function modifier_dw_shadow_bonus_as:OnRefresh(kv)
    self.bonus_as = kv.attackspeed
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