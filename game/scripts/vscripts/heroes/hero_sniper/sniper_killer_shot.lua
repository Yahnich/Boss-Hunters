sniper_killer_shot = class({})

function sniper_killer_shot:Spawn()
	self.projectileTable = self.projectileTable or {}
end

function sniper_killer_shot:GetCastPoint()
	return self:GetSpecialValueFor("AbilityCastPoint")
end

function sniper_killer_shot:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())

	target:AddNewModifier( caster, self, "modifier_sniper_assassinate", {} )
	return true
end

function sniper_killer_shot:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		enemy:RemoveModifierByName("modifier_sniper_assassinate")
	end
end

function sniper_killer_shot:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Ability.Assassinate", self:GetCaster())
	EmitSoundOn("Hero_Sniper.AssassinateProjectile", self:GetCaster())
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if enemy:HasModifier("modifier_sniper_assassinate") then
			self:LaunchAssassinate(enemy, 1, caster, self)
		end
	end
end

function sniper_killer_shot:LaunchAssassinate( target, power, source)
	self.projectileTable = self.projectileTable or {}
	local projectile = self:FireTrackingProjectile("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf", target, self:GetSpecialValueFor("speed"), {source = source or self:GetCaster()}, TernaryOperator( DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, source ~= nil, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION ), false, true, 100)
	self.projectileTable[projectile] = {impact_power = power or 1}
	return projectile
end

function sniper_killer_shot:OnProjectileHitHandle(target, vLocation, projectile)
	local caster = self:GetCaster()
	local aspd = self:GetSpecialValueFor("aspd")
	local debuff_duration = self:GetSpecialValueFor("debuff_duration")
	local assist_duration = self:GetSpecialValueFor("assist_duration")

	if target and not target:TriggerSpellAbsorb( ability ) then
		local impact_power = self.projectileTable[projectile].impact_power
		EmitSoundOn("Hero_Sniper.AssassinateDamage", caster)
		self:Stun(target, self:GetSpecialValueFor("ministun_duration") * impact_power )
		self:DealDamage(caster, target, self:GetSpecialValueFor("damage") * impact_power )
	
		local bonusDamagePct = self:GetSpecialValueFor("attack_factor")
		caster:PerformGenericAttack(target, true, {bonusDamagePct = bonusDamagePct, ability = self})

		if not target:IsAlive() then
			if aspd ~= 0 then
				if not caster:FindModifierByName("modifier_sniper_killer_shot_bargain") then
					caster:AddNewModifier(caster, self, "modifier_sniper_killer_shot_bargain", {})
					caster:FindModifierByName("modifier_sniper_killer_shot_bargain"):SetStackCount(1)
				end
			else
				caster:FindModifierByName("modifier_sniper_killer_shot_bargain"):IncrementStackCount()
			end
			caster:RefreshAllCooldowns(false)
		else
			if aspd ~= 0 and target:HasModifier("modifier_sniper_assassinate") then
				target:AddNewModifier(caster, self, "modifier_sniper_killer_shot_assist", {duration = assist_duration})
			end
		end

		if debuff_duration ~= 0 then
			target:AddNewModifier(caster, self, "modifier_sniper_killer_shot_sleeper", {duration = debuff_duration})
		end
		target:RemoveModifierByName("modifier_sniper_assassinate")
		self.projectileTable[projectile] = nil
	end
end

modifier_sniper_killer_shot_assist = class({})
LinkLuaModifier("modifier_sniper_killer_shot_assist", "heroes/hero_sniper/sniper_killer_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_killer_shot_assist:OnCreated()
	self.stack_cap = self:GetSpecialValueFor("stack_cap")
end

function modifier_sniper_killer_shot_assist:IsDebuff()
	return true
end

function modifier_sniper_killer_shot_assist:IsPurgable()
	return false
end

function modifier_sniper_killer_shot_assist:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()

	local buff = caster:FindModifierByName("modifier_sniper_killer_shot_bargain")

	if not parent:IsAlive() then
		if not buff then
			buff:SetStackCount(1)
		else
			buff:IncrementStackCount()
		end
	end
end

modifier_sniper_killer_shot_sleeper = class({})
LinkLuaModifier("modifier_sniper_killer_shot_sleeper", "heroes/hero_sniper/sniper_killer_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_killer_shot_sleeper:IsDebuff()
	return true
end

function modifier_sniper_killer_shot_sleeper:IsPurgable()
	return false
end

function modifier_sniper_killer_shot_sleeper:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:GetParent():SetRenderColor(226, 232, 107)
	end
end

function modifier_sniper_killer_shot_sleeper:OnRefresh()
	self.incoming_dmg = self:GetSpecialValueFor("incoming_dmg")
end

function modifier_sniper_killer_shot_sleeper:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_sniper_killer_shot_sleeper:GetModifierIncomingDamage_Percentage()
	return self.incoming_dmg
end

function modifier_sniper_killer_shot_sleeper:GetStatusEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf"
end

function modifier_sniper_killer_shot_sleeper:OnDestroy()
	if IsServer() then
		self:GetParent():SetRenderColor(255,255,255)
	end
end

modifier_sniper_killer_shot_bargain = class({})
LinkLuaModifier("modifier_sniper_killer_shot_bargain", "heroes/hero_sniper/sniper_killer_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_killer_shot_bargain:IsBuff()
	return true
end

function modifier_sniper_killer_shot_bargain:IsPurgable()
	return false
end

function modifier_sniper_killer_shot_bargain:OnCreated()
	self:OnRefresh()
end

function modifier_sniper_killer_shot_bargain:OnRefresh()
	self.aspd = self:GetSpecialValueFor("aspd")
end

function modifier_sniper_killer_shot_bargain:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_sniper_killer_shot_bargain:GetModifierAttackSpeedBonus_Constant()
	return self.aspd * self:GetStackCount()
end