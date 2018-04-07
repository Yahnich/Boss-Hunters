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
	self:LaunchFrostArrow(target, true)
end

function drow_ranger_glacier_arrows:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function drow_ranger_glacier_arrows:LaunchFrostArrow(target, bAttack, source)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	EmitSoundOn("Hero_DrowRanger.FrostArrows", caster)
	caster:SpendMana(self:GetManaCost(-1), self)
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	local sourceT = source or caster
	local projTable = {
		EffectName = "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf",
		Ability = self,
		Target = target,
		Source = sourceT,
		bDodgeable = true,
		bProvidesVision = false,
		vSpawnOrigin = sourceT:GetAbsOrigin(),
		iMoveSpeed = caster:GetProjectileSpeed(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )
	caster:RevertProjectile()
end


function drow_ranger_glacier_arrows:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		if target:GetChillCount() < self:GetTalentSpecialValueFor("base_chill") then
			target:AddChill( self, caster, self:GetTalentSpecialValueFor("duration") )
			target:SetChillCount( self:GetTalentSpecialValueFor("base_chill"), self:GetTalentSpecialValueFor("duration") )
		else
			target:AddChill( self, caster, self:GetTalentSpecialValueFor("duration"), self:GetTalentSpecialValueFor("stack_chill") )
		end
	end
end

modifier_drow_ranger_glacier_arrows_autocast = class({})
LinkLuaModifier("modifier_drow_ranger_glacier_arrows_autocast", "heroes/hero_drow_ranger/drow_ranger_glacier_arrows", LUA_MODIFIER_MOTION_NONE)

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
			caster:SetProjectileModel("particles/units/heroes/hero_drow/drow_base_attack.vpcf")
		end
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() then
			if self:GetParent().autoAttackFromAbilityState then
				self:GetAbility():OnProjectileHit( params.target, params.target:GetAbsOrigin() )
			else
				self:GetAbility():LaunchFrostArrow(params.target)
			end
		end
	end
end