bs_bloodrage = class({})
LinkLuaModifier("modifier_bs_bloodrage", "heroes/hero_bloodseeker/bs_bloodrage", LUA_MODIFIER_MOTION_NONE)

function bs_bloodrage:IsStealable()
	return true
end

function bs_bloodrage:IsHiddenWhenStolen()
	return false
end

function bs_bloodrage:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("hero_bloodseeker.bloodRage", target)
	local duration = self:GetTalentSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_bs_bloodrage_1") and target ~= caster then
		caster:AddNewModifier(caster, self, "modifier_bs_bloodrage", {Duration = duration})
	end

	target:AddNewModifier(caster, self, "modifier_bs_bloodrage", {Duration = duration})
end

modifier_bs_bloodrage = class({})
function modifier_bs_bloodrage:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_bs_bloodrage:OnRefresh()
	if self:GetCaster() == self:GetParent() or self:GetCaster():HasTalent("special_bonus_unique_bs_bloodrage_2") then
		self.spell_amp = self:GetTalentSpecialValueFor("spell_amp_self")
		self.attack_speed = self:GetTalentSpecialValueFor("attack_speed_self")
	else
		self.spell_amp = self:GetTalentSpecialValueFor("spell_amp_ally")
		self.attack_speed = self:GetTalentSpecialValueFor("attack_speed_ally")
	end
	self.hp_loss = self:GetTalentSpecialValueFor("hp_loss") / 100
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_bs_bloodrage_1")
end

function modifier_bs_bloodrage:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if self.talent1 then
		-- parent:HealEvent( parent:GetMaxHealth() * self.hp_loss * 0.1, ability, caster, true )
	else
		ability:DealDamage( parent, parent, parent:GetMaxHealth() * self.hp_loss * (-0.1), {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	end
end

function modifier_bs_bloodrage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end

function modifier_bs_bloodrage:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_bs_bloodrage:GetModifierAttackSpeedBonus()
	return self.attack_speed
end

function modifier_bs_bloodrage:GetModifierHealthRegenPercentage()
	if self.talent1 then
		if IsServer() then
			local delta = GameRules:GetGameTime() - (self.deltaTime or GameRules:GetGameTime())
			self:GetCaster().statsDamageHealed = (self:GetCaster().statsDamageHealed or 0) + math.min(  self:GetParent():GetMaxHealth() * self.hp_loss * delta, self:GetParent():GetHealthDeficit() )
			self.deltaTime = GameRules:GetGameTime()
		end
		return self.hp_loss
	end
end

function modifier_bs_bloodrage:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end

function modifier_bs_bloodrage:GetStatusEffectName()
	return "particles/status_fx/status_effect_bloodrage.vpcf"
end

function modifier_bs_bloodrage:StatusEffectPriority()
	return 10
end

function modifier_bs_bloodrage:IsDebuff()
	return not self.talent1
end