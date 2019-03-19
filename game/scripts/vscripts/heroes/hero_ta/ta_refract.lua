ta_refract = class({})
LinkLuaModifier( "modifier_ta_refract", "heroes/hero_ta/ta_refract.lua", LUA_MODIFIER_MOTION_NONE )

function ta_refract:IsStealable()
	return true
end

function ta_refract:IsHiddenWhenStolen()
	return false
end

function ta_refract:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_TemplarAssassin.Refraction", caster)

	caster:AddNewModifier(caster, self, "modifier_ta_refract", {Duration = self:GetTalentSpecialValueFor("duration")}):SetStackCount(self:GetTalentSpecialValueFor("block_count"))
end

modifier_ta_refract = ({})
function modifier_ta_refract:OnCreated(table)
	self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
		self:AddEffect(nfx)
		self:GetAbility():StartDelayedCooldown()
		if self:GetCaster():HasTalent("special_bonus_unique_ta_refract_1") then self:StartIntervalThink( self:GetCaster():FindTalentValue("special_bonus_unique_ta_refract_1") ) end
	end
end

function modifier_ta_refract:OnRefresh(table)
	self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
		if self:GetCaster():HasTalent("special_bonus_unique_ta_refract_1") then self:StartIntervalThink( self:GetCaster():FindTalentValue("special_bonus_unique_ta_refract_1") ) end
	end
end

function modifier_ta_refract:OnIntervalThink()
	self:GetCaster():Dispel(self:GetCaster(), true)
end

function modifier_ta_refract:OnRemoved()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_ta_refract:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_ta_refract:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			EmitSoundOn("Hero_TemplarAssassin.Refraction.Damage", params.target)
		elseif params.target == self:GetParent() then
			EmitSoundOn("Hero_TemplarAssassin.Refraction.Absorb", self:GetParent())
		end
	end
end

function modifier_ta_refract:GetModifierPreAttack_BonusDamage()
	return self.dmg
end

function modifier_ta_refract:GetModifierTotal_ConstantBlock(params)
	if self:GetStackCount() > 0 then
		self:DecrementStackCount()
		return params.original_damage + 1
	end
end