drow_ranger_glacier_arrows = class({})

function drow_ranger_glacier_arrows:IsStealable()
	return false
end

function drow_ranger_glacier_arrows:IsHiddenWhenStolen()
	return false
end

function drow_ranger_glacier_arrows:OnAbilityPhaseStart()
	self:SetOverrideCastPoint( self:GetCaster():GetSecondsPerAttack() )
	return true
end

function drow_ranger_glacier_arrows:GetIntrinsicModifierName()
	return "modifier_drow_ranger_glacier_arrows_autocast"
end

function drow_ranger_glacier_arrows:OnSpellStart()
	local target = self:GetCursorTarget()
	self:LaunchSpear(target, true)
end

function drow_ranger_glacier_arrows:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function drow_ranger_glacier_arrows:LaunchSpear(target, bAttack)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	EmitSoundOn("Hero_Huskar.Burning_Spear.Cast", caster)
	local cost = self:GetTalentSpecialValueFor("health_cost")
	if caster:HasTalent("special_bonus_unique_drow_ranger_glacier_arrows_2") then 
		cost = 0
	elseif caster:HasTalent("special_bonus_unique_drow_ranger_glacier_arrows_1") then 
		cost = cost * 2
	end
	local newHP = caster:GetHealth() - cost
	caster:ModifyHealth( newHP, self, false, 0)
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


function drow_ranger_glacier_arrows:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		EmitSoundOn("Hero_Huskar.Burning_Spear", caster)
		if target:IsAlive() then self:BurnTarget( target ) end
	end
end

function drow_ranger_glacier_arrows:BurnTarget( target )
	local duration = self:GetTalentSpecialValueFor("duration")
	local burn = target:AddNewModifier(self:GetCaster(), self, "modifier_drow_ranger_glacier_arrows_debuff", {duration = duration})
	burn:AddIndependentStack(duration)
end

modifier_drow_ranger_glacier_arrows_autocast = class({})
LinkLuaModifier("modifier_drow_ranger_glacier_arrows_autocast", "heroes/hero_huskar/drow_ranger_glacier_arrows", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_glacier_arrows_autocast:IsHidden()
	return true
end

if IsServer() then
	function modifier_drow_ranger_glacier_arrows_autocast:OnCreated()
		self:StartIntervalThink(0.03)
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		if self:GetAbility():GetAutoCastState() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_huskar/huskar_base_attack.vpcf")
		end
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() then
			self:GetAbility():LaunchSpear(params.target)
		end
	end
end