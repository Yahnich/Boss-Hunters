chaos_knight_chaos_strike_ebf = class({})
-- Talents: 100% Cleave on crit / +15% crit chance

function chaos_knight_chaos_strike_ebf:GetIntrinsicModifierName()
	return "modifier_chaos_knight_chaos_strike_ebf"
end

function chaos_knight_chaos_strike_ebf:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_chaos_knight_chaos_strike_actCrit") then
		return "custom/chaos_knight_chaos_strike_active"
	else
		return "chaos_knight_chaos_strike"
	end
end


modifier_chaos_knight_chaos_strike_actCrit = class({})
LinkLuaModifier("modifier_chaos_knight_chaos_strike_actCrit", "heroes/hero_chaos_knight/chaos_knight_chaos_strike_ebf", LUA_MODIFIER_MOTION_NONE)


function modifier_chaos_knight_chaos_strike_actCrit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_chaos_knight_chaos_strike_actCrit:GetModifierPreAttack_CriticalStrike( params )
	local parent = self:GetParent()
	EmitSoundOn( "Hero_ChaosKnight.ChaosStrike", parent)
	ParticleManager:FireParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	self.crit = true
	return self:GetTalentSpecialValueFor("crit_damage")
end

function modifier_chaos_knight_chaos_strike_actCrit:OnAttackLanded( params )
	if params.attacker == self:GetParent() and self.crit then
		if params.attacker:HasTalent("special_bonus_unique_chaos_knight_chaos_strike_1") and not params.attacker:PassivesDisabled() then
			local damage = params.original_damage * params.attacker:FindTalentValue("special_bonus_unique_chaos_knight_chaos_strike_1") / 100
			DoCleaveAttack(params.attacker, params.target, self:GetAbility(), damage, 150, 330, 625, "particles/items_fx/battlefury_cleave.vpcf" )
		end
	end
end

function modifier_chaos_knight_chaos_strike_actCrit:OnTakeDamage( params )
	if params.attacker == self:GetParent() and not params.inflictor then
		self:Destroy()
		params.attacker:Lifesteal(self:GetAbility(), self:GetTalentSpecialValueFor("lifesteal"), params.damage)
	end
end

modifier_chaos_knight_chaos_strike_ebf = class({})
LinkLuaModifier("modifier_chaos_knight_chaos_strike_ebf", "heroes/hero_chaos_knight/chaos_knight_chaos_strike_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_chaos_knight_chaos_strike_ebf:OnCreated()
	self.activation_delay = self:GetTalentSpecialValueFor("activation_delay")
	self.crit_damage = self:GetTalentSpecialValueFor("crit_damage")
	self.crit_chance = self:GetTalentSpecialValueFor("crit_chance")
	self.talent = self:GetParent():HasTalent("special_bonus_unique_chaos_knight_chaos_strike_1")
	if IsServer() then
		self.timer = self.activation_delay
		self:StartIntervalThink(0.1)
	end
end

function modifier_chaos_knight_chaos_strike_ebf:OnRefresh()
	self.activation_delay = self:GetTalentSpecialValueFor("activation_delay")
	self.crit_damage = self:GetTalentSpecialValueFor("crit_damage")
	self.crit_chance = self:GetTalentSpecialValueFor("crit_chance")
	self.talent = self:GetParent():HasTalent("special_bonus_unique_chaos_knight_chaos_strike_1")
	if IsServer() then
		self.timer = self.activation_delay
		self:StartIntervalThink(0.1)
	end
end

function modifier_chaos_knight_chaos_strike_ebf:OnIntervalThink()
	if self.timer <= 0 then
		self.timer = self.activation_delay
		self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_chaos_knight_chaos_strike_actCrit", {})
	elseif not self:GetParent():HasModifier("modifier_chaos_knight_chaos_strike_actCrit") then
		self.timer = self.timer - 0.1
	end
end

function modifier_chaos_knight_chaos_strike_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_chaos_knight_chaos_strike_ebf:GetModifierPreAttack_CriticalStrike( params )
	if self:RollPRNG( self.crit_chance ) and not params.attacker:PassivesDisabled() and not self:GetParent():HasModifier("modifier_chaos_knight_chaos_strike_actCrit") then
		local parent = self:GetParent()
		self.on_crit = true
		EmitSoundOn( "Hero_ChaosKnight.ChaosStrike", parent)
		ParticleManager:FireParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		self.timer = self.activation_delay
		return self.crit_damage
	else
		self.on_crit = false
	end
end

function modifier_chaos_knight_chaos_strike_ebf:OnAttackLanded( params )
	if self.on_crit and params.attacker == self:GetParent() then
		if self.talent and not params.attacker:PassivesDisabled() then
			local damage = params.original_damage * params.attacker:FindTalentValue("special_bonus_unique_chaos_knight_chaos_strike_1") / 100
			DoCleaveAttack(params.attacker, params.target, self:GetAbility(), damage, 150, 330, 625, "particles/items_fx/battlefury_cleave.vpcf" )
		end
	end
end

function modifier_chaos_knight_chaos_strike_ebf:OnTakeDamage( params )
	if self.on_crit and params.attacker == self:GetParent() and not params.inflictor then
		params.attacker:Lifesteal(self:GetAbility(), self:GetTalentSpecialValueFor("lifesteal"), params.damage)
		self.on_crit = false  -- last in damage order, don't set to false before this
	end
end

function modifier_chaos_knight_chaos_strike_ebf:IsHidden()
	return true
end