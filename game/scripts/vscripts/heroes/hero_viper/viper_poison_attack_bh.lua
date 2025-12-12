viper_poison_attack_bh = class({})

function viper_poison_attack_bh:IsStealable()
	return false
end

function viper_poison_attack_bh:GetIntrinsicModifierName()
	return "modifier_viper_poison_attack_bh_autocast"
end

function viper_poison_attack_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:RefundManaCost()
	self:EndCooldown()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end

function viper_poison_attack_bh:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function viper_poison_attack_bh:LaunchPoisonAttack(target, bAttack)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	caster:EmitSound("hero_viper.poisonAttack.Cast")
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	local projTable = {
		EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
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
	
	self:SpendMana()
	self:SetCooldown()
end

function viper_poison_attack_bh:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration") + 0.1
		target:AddNewModifier( caster, self, "modifier_viper_poison_attack_bh", {duration = duration})
		target:EmitSound("hero_viper.PoisonAttack.Target")
	end
end

modifier_viper_poison_attack_bh = class({})
LinkLuaModifier("modifier_viper_poison_attack_bh", "heroes/hero_viper/viper_poison_attack_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_viper_poison_attack_bh:OnCreated()
	self:OnRefresh()
end

function modifier_viper_poison_attack_bh:OnRefresh()
	self.mr = self:GetSpecialValueFor("mr_reduction")
	self.ms = self:GetSpecialValueFor("bonus_movement_speed")
	self.dmg = self:GetSpecialValueFor("damage")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_viper_poison_attack_1")
	self.talent1Threshold = self:GetCaster():FindTalentValue("special_bonus_unique_viper_poison_attack_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_viper_poison_attack_2")
	if IsServer() then
		if self:GetStackCount() < self:GetSpecialValueFor("max_stacks") then
			self:IncrementStackCount()
		end
		local tick = ( self:GetRemainingTime() / self:GetSpecialValueFor("duration") + 0.1 ) * 1
		if tick - (self.tick or 0) > 0.03 then
			self.tick = tick
			self:StartIntervalThink( self.tick )
		end
	end
end

function modifier_viper_poison_attack_bh:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local damage = ability:DealDamage( self:GetCaster(), parent, self.dmg * self:GetStackCount(), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
	if self.talent2 then
		self.talent2Bomb = (self.talent2Bomb or 0) + damage
	end
	if self.talent1 and self:GetStackCount() > self.talent1Threshold then
		ability:Stun(parent, 0.1)
	end
end

function modifier_viper_poison_attack_bh:OnDestroy()
	if self.talent2Bomb then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local radius = caster:FindTalentValue("special_bonus_unique_viper_poison_attack_2")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), radius ) ) do
			if enemy ~= parent then
				ability:DealDamage( caster, enemy, self.talent2Bomb, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION } )
				if self.talent1 and self:GetStackCount() > self.talent1Threshold then
					ability:Stun(enemy, 0.1)
				end
			end
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_viper/viper_nethertoxin_impact_vibe.vpcf", PATTACH_POINT_FOLLOW, parent )
	end
end

function modifier_viper_poison_attack_bh:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_viper_poison_attack_bh:GetModifierMagicalResistanceBonus()
	return self.mr * self:GetStackCount()
end

function modifier_viper_poison_attack_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetStackCount()
end

function modifier_viper_poison_attack_bh:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

modifier_viper_poison_attack_bh_autocast = class({})
LinkLuaModifier("modifier_viper_poison_attack_bh_autocast", "heroes/hero_viper/viper_poison_attack_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_viper_poison_attack_bh_autocast:IsHidden()
	return true
end

if IsServer() then
	function modifier_viper_poison_attack_bh_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_viper_poison_attack_bh_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target then
			if ( ( self:GetAbility():GetAutoCastState() and self:GetAbility():IsFullyCastable() ) or self:GetAbility().forceCast) and params.attacker:GetMana() > self:GetAbility():GetManaCost(-1) and not self:GetParent():GetAttackTarget():IsMagicImmune() then
				self:GetAbility():LaunchPoisonAttack(params.target)
				self:GetAbility().forceCast = false
			else
				params.attacker:SetProjectileModel("particles/units/heroes/hero_viper/viper_base_attack.vpcf")
			end
		end
	end
end