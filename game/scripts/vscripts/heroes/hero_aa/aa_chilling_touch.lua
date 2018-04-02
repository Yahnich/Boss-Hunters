aa_chilling_touch = class({})
LinkLuaModifier("modifier_aa_chilling_touch", "heroes/hero_aa/aa_chilling_touch", LUA_MODIFIER_MOTION_NONE)

function aa_chilling_touch:OnSpellStart()
	local caster = self:GetCaster()
	local radius = 5000
	ParticleManager:FireParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch.vpcf", PATTACH_POINT, caster, {[0]=caster:GetAbsOrigin(),[1]=Vector(radius,radius,radius)})
	EmitSoundOn("Hero_Ancient_Apparition.ChillingTouchCast", caster)

	local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,friend in pairs(friends) do
		if friend:IsHero() then
			friend:AddNewModifier(caster, self, "modifier_aa_chilling_touch", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_aa_chilling_touch = class({})
function modifier_aa_chilling_touch:OnCreated(table)
	if IsServer() then 
		self.damage = self:GetSpecialValueFor("bonus_damage")
	end

	if self:GetParent() == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_aa_chilling_touch_2") then
		self.as = self:GetCaster():FindTalentValue("special_bonus_unique_aa_chilling_touch_2")
	else
		self.as = 0
	end 
end

function modifier_aa_chilling_touch:OnRefresh(table)
	if IsServer() then 
		self.damage = self:GetSpecialValueFor("bonus_damage") 
	end

	if self:GetParent() == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_aa_chilling_touch_2") then
		self.as = self:GetCaster():FindTalentValue("special_bonus_unique_aa_chilling_touch_2")
	else
		self.as = 0
	end 
end

function modifier_aa_chilling_touch:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_aa_chilling_touch:OnAttackLanded(params)
    if IsServer() and params.attacker == self:GetParent() and params.target and params.target:GetTeam() ~= self:GetCaster():GetTeam() then
    	local damage = self:GetAbility():DealDamage(params.attacker, params.target, self:GetSpecialValueFor("bonus_damage"), {damage_type=DAMAGE_TYPE_MAGICAL,damage_flags=DOTA_DAMAGE_FLAG_NONE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
    	params.target:AddChill(nil, self:GetCaster(), self:GetSpecialValueFor("duration"))
    end
end

function modifier_aa_chilling_touch:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_aa_chilling_touch:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end