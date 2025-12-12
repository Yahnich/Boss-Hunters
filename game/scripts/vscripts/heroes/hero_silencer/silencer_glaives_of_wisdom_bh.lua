silencer_glaives_of_wisdom_bh = class({})

function silencer_glaives_of_wisdom_bh:IsStealable()
	return false
end

function silencer_glaives_of_wisdom_bh:GetIntrinsicModifierName()
	return "modifier_silencer_glaives_of_wisdom_bh_autocast"
end

function silencer_glaives_of_wisdom_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:RefundManaCost()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end

function silencer_glaives_of_wisdom_bh:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function silencer_glaives_of_wisdom_bh:LaunchGlaivesOfWisdom(target, bAttack)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	caster:EmitSound("Hero_Silencer.GlaivesOfWisdom")
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	local projTable = {
		EffectName = "particles/units/heroes/hero_silencer/silencer_glaives_of_wisdom.vpcf",
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

function silencer_glaives_of_wisdom_bh:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		local damage = caster:GetIntellect( false) * self:GetSpecialValueFor("intellect_damage_pct") / 100
		if caster:HasTalent("special_bonus_unique_silencer_glaives_of_wisdom_1") and target:IsSilenced() then
			damage = damage * self:GetParent():FindTalentValue("special_bonus_unique_silencer_glaives_of_wisdom_1")
		end
		self:DealDamage(caster, target, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
end

modifier_silencer_glaives_of_wisdom_bh_autocast = class({})
LinkLuaModifier("modifier_silencer_glaives_of_wisdom_bh_autocast", "heroes/hero_silencer/silencer_glaives_of_wisdom_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_silencer_glaives_of_wisdom_bh_autocast:IsHidden()
	return true
end

if IsServer() then
	function modifier_silencer_glaives_of_wisdom_bh_autocast:OnCreated()
		self:StartIntervalThink(0.03)
	end
	
	function modifier_silencer_glaives_of_wisdom_bh_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		if self:GetAbility():GetAutoCastState() and self:GetParent():GetMana() > self:GetAbility():GetManaCost(-1) and self:GetParent():GetAttackTarget() and not self:GetParent():GetAttackTarget():IsMagicImmune() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_silencer/silencer_base_attack.vpcf")
		end
	end
	
	function modifier_silencer_glaives_of_wisdom_bh_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_silencer_glaives_of_wisdom_bh_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and params.attacker:GetMana() > self:GetAbility():GetManaCost(-1) and not self:GetParent():GetAttackTarget():IsMagicImmune() then
			self:GetAbility():LaunchGlaivesOfWisdom(params.target)
			self:GetAbility():SpendMana()
			if self:GetParent():HasTalent("special_bonus_unique_silencer_glaives_of_wisdom_2") then
				self:GetParent():HealEvent( self:GetAbility():GetManaCost(-1) * self:GetParent():FindTalentValue("special_bonus_unique_silencer_glaives_of_wisdom_2"), self:GetAbility(), self:GetParent()  )
			end
			self:GetAbility().forceCast = false
		end
	end
end