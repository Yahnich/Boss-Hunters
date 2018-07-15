lycan_howl_bh = class({})

function lycan_howl_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("howl_duration")
	if not GameRules:IsDaytime() then
		duration = duration * 2
	end
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		ally:AddNewModifier(caster, self, "modifier_lycan_howl_bh_buff", {duration = duration})
	end
	
	if caster:HasTalent("special_bonus_unique_lycan_howl_2") then
		local fearDur = caster:FindTalentValue("special_bonus_unique_lycan_howl_2", "duration")
		if not GameRules:IsDaytime() then
			fearDur = fearDur * 2
		end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_lycan_howl_2") ) ) do
			enemy:AddNewModifier(caster, self, "modifier_lycan_howl_bh_fear", {duration = fearDur})
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("Hero_Lycan.Howl", caster)
end

modifier_lycan_howl_bh_buff = class({})
LinkLuaModifier("modifier_lycan_howl_bh_buff", "heroes/hero_lycan/lycan_howl_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_howl_bh_buff:OnCreated()
	self.hp = self:GetTalentSpecialValueFor("hero_bonus_hp")
	self.damage = self:GetTalentSpecialValueFor("hero_bonus_damage")
	if not self:GetParent():IsHero() then
		self.hp = self:GetTalentSpecialValueFor("unit_bonus_damage")
		self.damage = self:GetTalentSpecialValueFor("unit_bonus_hp")
	end
	if not GameRules:IsDaytime() then
		self.hp = self.hp * 2
		self.damage = self.damage * 2
	end
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_lycan_howl_bh_buff:OnIntervalThink()
	self:GetParent():HealEvent( self.hp, self:GetAbility(), self:GetCaster() )
	self:StartIntervalThink(-1)
end

function modifier_lycan_howl_bh_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_lycan_howl_bh_buff:GetModifierExtraHealthBonus()
	return self.hp
end

function modifier_lycan_howl_bh_buff:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_lycan_howl_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end


modifier_lycan_howl_bh_fear = class({})
LinkLuaModifier("modifier_lycan_howl_bh_fear", "heroes/hero_lycan/lycan_howl_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_lycan_howl_bh_fear:OnCreated()
		self:StartIntervalThink(0.2)
	end
	
	function modifier_lycan_howl_bh_fear:OnIntervalThink()
		local direction = CalculateDirection(self:GetParent(), self:GetCaster())
		self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + direction * self:GetParent():GetIdealSpeed() * 0.2)
	end
end

function modifier_lycan_howl_bh_fear:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function modifier_lycan_howl_bh_fear:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end