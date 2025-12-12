mirana_stardust_reflection = class({})

function mirana_stardust_reflection:IsStealable()
    return true
end

function mirana_stardust_reflection:IsHiddenWhenStolen()
    return false
end

function mirana_stardust_reflection:OnAbilityPhaseStart()
    ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_moonlight_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
    return true
end

function mirana_stardust_reflection:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Ability.MoonlightShadow", caster)

    local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
    for _,friend in pairs(friends) do
        ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_POINT_FOLLOW, friend, {})
        friend:AddNewModifier(caster, self, "modifier_moonlight_duration", {Duration = self:GetSpecialValueFor("duration")})
        friend:AddNewModifier(caster, self, "modifier_moonlight_fade", {Duration = self:GetSpecialValueFor("fade_delay")})
    end
end

modifier_moonlight_duration = class({})
LinkLuaModifier("modifier_moonlight_duration", "heroes/hero_mirana/mirana_stardust_reflection", LUA_MODIFIER_MOTION_NONE)

function modifier_moonlight_duration:OnCreated()
	self.ms = self:GetSpecialValueFor("movespeed")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_mirana_stardust_reflection_1")
	self.talent1Cdr = 0.33 * (self:GetCaster():FindTalentValue("special_bonus_unique_mirana_stardust_reflection_1") / 100)
	self.talent1Amp = self:GetCaster():FindTalentValue("special_bonus_unique_mirana_stardust_reflection_1", "amp")
	if self.talent1 and IsServer() then
		self:StartIntervalThink(0.33)
	end
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_mirana_stardust_reflection_2")
	self.talent2Dmg = self:GetCaster():FindTalentValue("special_bonus_unique_mirana_stardust_reflection_2", "dmg") / 100
	self.talent2Evasion = self:GetCaster():FindTalentValue("special_bonus_unique_mirana_stardust_reflection_2")
end

function modifier_moonlight_duration:OnRemoved()
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_moonlight_fade")
        self:GetParent():RemoveModifierByName("modifier_moonlight_invisibility")
    end
end

function modifier_moonlight_duration:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
		local ability = parent:GetAbilityByIndex( i )
		if ability and not ability:IsCooldownReady() then
			ability:ModifyCooldown( -self.talent1Cdr  )
		end
	end
end

function modifier_moonlight_duration:GetEffectName()
    return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end

function modifier_moonlight_duration:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_moonlight_duration:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_EVENT_ON_ABILITY_EXECUTED,
				MODIFIER_PROPERTY_EVASION_CONSTANT,
				MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
            }
    return funcs
end

function modifier_moonlight_duration:GetModifierEvasion_Constant()
    return self.talent2Evasion
end

function modifier_moonlight_duration:GetModifierSpellAmplify_Percentage()
    return self.talent1Amp
end

function modifier_moonlight_duration:GetModifierMoveSpeedBonus_Percentage()
    return self.ms
end

function modifier_moonlight_duration:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
			if self.talent2 and params.attacker:HasModifier("modifier_moonlight_invisibility") then
				self:GetAbility():DealDamage( self:GetCaster(), params.target, params.attacker:GetAgility() * self.talent2Dmg, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
			end
            params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_moonlight_fade", {Duration = self:GetSpecialValueFor("fade_delay")})
        end
    end
end

function modifier_moonlight_duration:OnAbilityExecuted(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_moonlight_fade", {Duration = self:GetSpecialValueFor("fade_delay")})
        end
    end
end

modifier_moonlight_fade = class({})
LinkLuaModifier("modifier_moonlight_fade", "heroes/hero_mirana/mirana_stardust_reflection", LUA_MODIFIER_MOTION_NONE)
function modifier_moonlight_fade:OnCreated(table)
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_moonlight_invisibility")
    end
end

function modifier_moonlight_fade:OnRemoved()
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_moonlight_invisibility", {})
    end
end

function modifier_moonlight_fade:IsHidden()
    return true
end

modifier_moonlight_invisibility = class({})
LinkLuaModifier("modifier_moonlight_invisibility", "heroes/hero_mirana/mirana_stardust_reflection", LUA_MODIFIER_MOTION_NONE)

function modifier_moonlight_invisibility:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true}
end

function modifier_moonlight_invisibility:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL }
end

function modifier_moonlight_invisibility:GetModifierInvisibilityLevel()
	return 1.0
end