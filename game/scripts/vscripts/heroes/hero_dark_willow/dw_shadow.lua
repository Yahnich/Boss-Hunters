dw_shadow = class({})
LinkLuaModifier("modifier_dw_shadow", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_shadow_damage", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_shadow_bonus_as", "heroes/hero_dark_willow/dw_shadow", LUA_MODIFIER_MOTION_NONE)

function dw_shadow:IsStealable()
    return true
end

function dw_shadow:IsHiddenWhenStolen()
    return false
end

function dw_shadow:OnSpellStart()
	local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_dw_shadow_damage")

	if caster:HasModifier("modifier_dw_shadow") then
		caster:RemoveModifierByName("modifier_dw_shadow")
		self:RefundManaCost()
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

		if caster:HasTalent("special_bonus_unique_dw_shadow_1") then
			local ability = caster:FindAbilityByName("dw_bramble")
			ability:PlantBush(vLocation)
		end
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

    	self:StartIntervalThink(FrameTime())
    end
end

function modifier_dw_shadow:OnRefresh(table)
    if IsServer() then
    	self:GetAbility().damage = 0
    	self.damage = self:GetTalentSpecialValueFor("damage") * FrameTime()

    	self.manaDrain = self:GetParent():GetMaxMana() * self:GetTalentSpecialValueFor("mana_drain")/100 * FrameTime()

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