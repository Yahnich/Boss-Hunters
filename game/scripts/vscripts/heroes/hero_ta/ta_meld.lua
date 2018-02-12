ta_meld = class({})
LinkLuaModifier( "modifier_ta_meld", "heroes/hero_ta/ta_meld.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ta_meld_armor", "heroes/hero_ta/ta_meld.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ta_meld_enemy", "heroes/hero_ta/ta_meld.lua", LUA_MODIFIER_MOTION_NONE )


function ta_meld:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_ta_meld", {Duration = self:GetSpecialValueFor("invis_duration")})
	caster:AddNewModifier(caster, self, "modifier_ta_meld_armor", {})
end

modifier_ta_meld_armor = ({})
function modifier_ta_meld_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_ta_meld_armor:GetModifierPreAttack_BonusDamage()
	return self:GetTalentSpecialValueFor("bonus_damage")
end

function modifier_ta_meld_armor:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_ta_meld_enemy", {Duration = self:GetTalentSpecialValueFor("reduc_duration")})
			if params.attacker:HasTalent("special_bonus_unique_ta_meld_2") then
				params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_disarmed", {Duration = params.attacker:FindTalentValue("special_bonus_unique_ta_meld_2")})
			end
			self:Destroy()
		end
	end
end

modifier_ta_meld = ({})
function modifier_ta_meld:OnCreated(table)
	if IsServer() then
		--self:GetCaster():SetThreat(0)
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", {Duration = self:GetSpecialValueFor("invis_duration")})
	end
end

function modifier_ta_meld:OnRemoved()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_invisible")
	end
end
function modifier_ta_meld:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER
    }
    return funcs
end

function modifier_ta_meld:OnOrder(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_ta_meld:IsHidden()
	return true
end

modifier_ta_meld_enemy = ({})
function modifier_ta_meld_enemy:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_ta_meld_enemy:GetModifierPhysicalArmorBonus()
	return self:GetTalentSpecialValueFor("armor_reduc")
end

function modifier_ta_meld_enemy:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld.vpcf"
end