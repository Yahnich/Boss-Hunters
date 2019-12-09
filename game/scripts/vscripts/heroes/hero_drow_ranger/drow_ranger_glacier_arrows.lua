drow_ranger_glacier_arrows = class({})

function drow_ranger_glacier_arrows:IsStealable()
	return false
end

function drow_ranger_glacier_arrows:IsHiddenWhenStolen()
	return false
end

function drow_ranger_glacier_arrows:GetCastPoint()
	return 0
end

function drow_ranger_glacier_arrows:GetIntrinsicModifierName()
	return "modifier_drow_ranger_glacier_arrows_autocast"
end

function drow_ranger_glacier_arrows:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
	self:RefundManaCost()
end

function drow_ranger_glacier_arrows:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function drow_ranger_glacier_arrows:LaunchFrostArrow(target, bAttack, source)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	EmitSoundOn("Hero_DrowRanger.FrostArrows", caster)
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	local sourceT = source or caster
	self:FireTrackingProjectile("particles/units/heroes/hero_drow/drow_frost_arrow.vpcf", target, caster:GetProjectileSpeed(), {source = sourceT}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
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
		self:DealDamage( caster, target, caster:GetLevel(), {damage_type = DAMAGE_TYPE_MAGICAL} )
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
		local ability = self:GetAbility()
		if ability:GetAutoCastState() or ability.forceCast then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_drow/drow_base_attack.vpcf")
		end
		if ability:GetAutoCastState() and not ability:IsOwnersManaEnough() then
			ability:ToggleAutoCast( )
		end
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_drow_ranger_glacier_arrows_autocast:OnAttack(params)
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		if params.attacker == self:GetParent() and params.target and (ability:GetAutoCastState() or ability.forceCast) and ability:IsOwnersManaEnough() and not params.target:IsMagicImmune() then
			caster:SpendMana(ability:GetManaCost(-1), ability)
			ability.forceCast = false
			if self:GetParent().autoAttackFromAbilityState then
				self:GetAbility():OnProjectileHit( params.target, params.target:GetAbsOrigin() )
			else
				self:GetAbility():LaunchFrostArrow(params.target)
			end
		end
	end
end