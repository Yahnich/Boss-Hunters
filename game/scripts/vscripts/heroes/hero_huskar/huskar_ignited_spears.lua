huskar_ignited_spears = class({})

function huskar_ignited_spears:IsStealable()
	return false
end

function huskar_ignited_spears:IsHiddenWhenStolen()
	return false
end

function huskar_ignited_spears:GetIntrinsicModifierName()
	return "modifier_huskar_ignited_spears_autocast"
end

function huskar_ignited_spears:GetCastPoint()
	return 0
end

function huskar_ignited_spears:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
	self:RefundManaCost()
end


function huskar_ignited_spears:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function huskar_ignited_spears:LaunchSpear(target, bAttack)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	EmitSoundOn("Hero_Huskar.Burning_Spear.Cast", caster)
	local costPct = self:GetSpecialValueFor("health_cost")
	local cost = caster:GetHealth() * costPct / 100
	if cost > 0 then
		local newHP = math.max( caster:GetHealth() - cost, 1 )
		caster:ModifyHealth( newHP, self, false, 0)
	end
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	local projTable = {
		EffectName = "particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf",
		Ability = self,
		Target = target,
		Source = caster,
		bDodgeable = true,
		bProvidesVision = false,
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = caster:GetProjectileSpeed(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )
	caster:RevertProjectile()
end


function huskar_ignited_spears:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		EmitSoundOn("Hero_Huskar.Burning_Spear", caster)
		if target:IsAlive() then self:BurnTarget( target ) end
	end
end

function huskar_ignited_spears:BurnTarget( target )
	local duration = self:GetSpecialValueFor("duration")
	local burn = target:AddNewModifier(self:GetCaster(), self, "modifier_huskar_ignited_spears_debuff", {duration = duration})
	burn:AddIndependentStack(duration)
end

modifier_huskar_ignited_spears_autocast = class({})
LinkLuaModifier("modifier_huskar_ignited_spears_autocast", "heroes/hero_huskar/huskar_ignited_spears", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_ignited_spears_autocast:IsHidden()
	return true
end

if IsServer() then
	function modifier_huskar_ignited_spears_autocast:OnCreated()
		self:StartIntervalThink(0.03)
	end
	
	function modifier_huskar_ignited_spears_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		if (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and self:GetParent():GetMana() > self:GetAbility():GetManaCost(-1) and self:GetParent():GetAttackTarget() and not self:GetParent():GetAttackTarget():IsMagicImmune() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_huskar/huskar_base_attack.vpcf")
		end
	end
end	

function modifier_huskar_ignited_spears_autocast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end

function modifier_huskar_ignited_spears_autocast:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "health_cost" then
			return 1
		end
	end
end

function modifier_huskar_ignited_spears_autocast:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "health_cost"then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local percentageModifier = 1 + self:GetCaster():FindTalentValue("special_bonus_unique_huskar_ignited_spears_1", "cost") / 100 + self:GetCaster():FindTalentValue("special_bonus_unique_huskar_ignited_spears_2", "cost") / 100
			return flBaseValue * percentageModifier
		end
	end
end

function modifier_huskar_ignited_spears_autocast:OnAttack(params)
	local ability = self:GetAbility()
	if params.attacker == self:GetParent() and params.target and (ability:GetAutoCastState() or ability.forceCast) and ability:IsOwnersManaEnough() and not self:GetParent():GetAttackTarget():IsMagicImmune() then
		self:GetAbility():LaunchSpear(params.target)
		self:GetAbility():SpendMana()
		self:GetAbility().forceCast = false
	end
end

modifier_huskar_ignited_spears_debuff = class({})
LinkLuaModifier("modifier_huskar_ignited_spears_debuff", "heroes/hero_huskar/huskar_ignited_spears", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_huskar_ignited_spears_debuff:OnCreated()
		self.damage = self:GetSpecialValueFor("burn_damage")
		self:StartIntervalThink(1)
	end
	
	function modifier_huskar_ignited_spears_debuff:OnRefresh()
		self.damage = self:GetSpecialValueFor("burn_damage")
	end
	
	function modifier_huskar_ignited_spears_debuff:OnIntervalThink()
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * self:GetStackCount() )
	end
end

function modifier_huskar_ignited_spears_debuff:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end
