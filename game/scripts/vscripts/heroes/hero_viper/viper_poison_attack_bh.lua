viper_poison_attack_bh = class({})

function viper_poison_attack_bh:IsStealable()
	return false
end

function viper_poison_attack_bh:GetIntrinsicModifierName()
	return "modifier_viper_poison_attack_bh_autocast"
end

function viper_poison_attack_bh:GetCooldown( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_viper_poison_attack_2") then
		return 0
	else
		return self.BaseClass.GetCooldown( self, iLvl )
	end
end


function viper_poison_attack_bh:GetManaCost( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_viper_poison_attack_2") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
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
		local duration = self:GetTalentSpecialValueFor("duration") + 0.1
		if caster:HasTalent("special_bonus_unique_viper_poison_attack_1") then
			target:Paralyze(self, caster, caster:FindTalentValue("special_bonus_unique_viper_poison_attack_1"))
		end
		target:AddNewModifier( caster, self, "modifier_viper_poison_attack_bh", {duration = duration})
		target:EmitSound("hero_viper.PoisonAttack.Target")
	end
end

modifier_viper_poison_attack_bh = class({})
LinkLuaModifier("modifier_viper_poison_attack_bh", "heroes/hero_viper/viper_poison_attack_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_viper_poison_attack_bh:OnCreated()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.dmg = self:GetTalentSpecialValueFor("damage")
	if IsServer() then
		self.tick = ( self:GetRemainingTime() / self:GetTalentSpecialValueFor("duration") + 0.1 ) * 1
		self:StartIntervalThink( self.tick )
	end
end

function modifier_viper_poison_attack_bh:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.dmg = self:GetTalentSpecialValueFor("damage")
	if IsServer() then
		local tick = ( self:GetRemainingTime() / self:GetTalentSpecialValueFor("duration") + 0.1 ) * 1
		if tick - self.tick > 0.03 then
			self.tick = tick
			self:StartIntervalThink( self.tick )
		end
	end
end

function modifier_viper_poison_attack_bh:OnIntervalThink()
	local parent = self:GetParent()
	self:GetAbility():DealDamage( self:GetCaster(), parent, math.max( 1, ( 100 - parent:GetHealth()/parent:GetMaxHealth() * 100 ) * self.dmg ), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
end

function modifier_viper_poison_attack_bh:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_viper_poison_attack_bh:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_viper_poison_attack_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
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