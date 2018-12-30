huskar_ignited_spears = class({})

function huskar_ignited_spears:IsStealable()
	return false
end

function huskar_ignited_spears:IsHiddenWhenStolen()
	return false
end

function huskar_ignited_spears:OnAbilityPhaseStart()
	self:SetOverrideCastPoint( self:GetCaster():GetCastPoint(true) )
	return true
end

function huskar_ignited_spears:GetIntrinsicModifierName()
	return "modifier_huskar_ignited_spears_autocast"
end

function huskar_ignited_spears:OnSpellStart()
	local target = self:GetCursorTarget()
	self:LaunchSpear(target, true)
end

function huskar_ignited_spears:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function huskar_ignited_spears:LaunchSpear(target, bAttack)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	EmitSoundOn("Hero_Huskar.Burning_Spear.Cast", caster)
	local cost = self:GetTalentSpecialValueFor("health_cost") * ( 1 + caster:FindTalentValue("special_bonus_unique_huskar_ignited_spears_1", "cost")/100 + caster:FindTalentValue("special_bonus_unique_huskar_ignited_spears_2", "cost")/100 )
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
	local duration = self:GetTalentSpecialValueFor("duration")
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
		if self:GetAbility():GetAutoCastState() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_huskar/huskar_base_attack.vpcf")
		end
	end
	
	function modifier_huskar_ignited_spears_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_huskar_ignited_spears_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() then
			self:GetAbility():LaunchSpear(params.target)
		end
	end
end

modifier_huskar_ignited_spears_debuff = class({})
LinkLuaModifier("modifier_huskar_ignited_spears_debuff", "heroes/hero_huskar/huskar_ignited_spears", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_huskar_ignited_spears_debuff:OnCreated()
		self.damage = self:GetTalentSpecialValueFor("burn_damage")
		self:StartIntervalThink(1)
	end
	
	function modifier_huskar_ignited_spears_debuff:OnRefresh()
		self.damage = self:GetTalentSpecialValueFor("burn_damage")
	end
	
	function modifier_huskar_ignited_spears_debuff:OnIntervalThink()
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * self:GetStackCount() )
	end
end

function modifier_huskar_ignited_spears_debuff:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end
