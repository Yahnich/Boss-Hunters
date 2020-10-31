boss_arthromos_touch_of_decay = class({})

function boss_arthromos_touch_of_decay:GetIntrinsicModifierName()
	return "modifier_boss_arthromos_touch_of_decay"
end

modifier_boss_arthromos_touch_of_decay = class({})
LinkLuaModifier( "modifier_boss_arthromos_touch_of_decay", "bosses/boss_arthromos/boss_arthromos_touch_of_decay", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_arthromos_touch_of_decay:OnCreated()
	self.duration = self:GetSpecialValueFor("debuff_duration")
end

function modifier_boss_arthromos_touch_of_decay:OnRefresh()
	self:OnCreated()
end

function modifier_boss_arthromos_touch_of_decay:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_arthromos_touch_of_decay:OnAttackLanded(params)
	if not self:GetParent():PassivesDisabled() then
		if ( params.attacker == self:GetParent() and not params.target:IsMagicImmune() ) then
			params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_boss_arthromos_touch_of_decay_debuff", {duration = self.duration} )
		elseif ( params.target == self:GetParent() and not params.attacker:IsMagicImmune() ) then
			params.attacker:AddNewModifier( params.target, self:GetAbility(), "modifier_boss_arthromos_touch_of_decay_debuff", {duration = self.duration} )
		end
	end
end

function modifier_boss_arthromos_touch_of_decay:IsHidden()
	return true
end

modifier_boss_arthromos_touch_of_decay_debuff = class({})
LinkLuaModifier( "modifier_boss_arthromos_touch_of_decay_debuff", "bosses/boss_arthromos/boss_arthromos_touch_of_decay", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_arthromos_touch_of_decay_debuff:OnCreated()
	self.regen = self:GetSpecialValueFor("hp_pct") / 100
	if IsServer() then
		self:StartIntervalThink( 0.33 )
	end
end

function modifier_boss_arthromos_touch_of_decay_debuff:OnRefresh()
	self.regen = self:GetSpecialValueFor("hp_pct") / 100
	if IsServer() then
		self:StartIntervalThink( 0.33 )
	end
end

function modifier_boss_arthromos_touch_of_decay_debuff:OnIntervalThink()
	local damage =  self:GetParent():GetMaxHealth() * self.regen * 0.33
	local damageDealt = self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), math.abs(damage), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL} )
	self:GetCaster():HealEvent( damageDealt, self:GetAbility(), self:GetCaster() )
end

function modifier_boss_arthromos_touch_of_decay_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end