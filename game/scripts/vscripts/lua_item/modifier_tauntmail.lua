modifier_tauntmail = class({})

--------------------------------------------------------------------------------
function modifier_tauntmail:DeclareFunctions(params)
local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_tauntmail:IsHidden()
	return true
end

function modifier_tauntmail:IsBuff()
    if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return true
    end

    return false
end

--------------------------------------------------------------------------------

function modifier_tauntmail:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "reflect_pct" )
end

--------------------------------------------------------------------------------

function modifier_tauntmail:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "reflect_pct" )
end

--------------------------------------------------------------------------------

function modifier_tauntmail:OnTakeDamage(params)
    local hero = self:GetParent()
    local dmg = params.damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100
	if attacker:GetTeamNumber()  ~= hero:GetTeamNumber() then
		if params.unit == hero then
			dmg = dmg * reflectpct
			if dmgtype == DAMAGE_TYPE_PHYSICAL then
				local armorhero = hero:GetPhysicalArmorValue()
				local armorattacker = attacker:GetPhysicalArmorValue()
				local dmgreturn = dmg
				if armorhero > armorattacker and not GameRules._NewGamePlus then
					local dmgmulthero = 100 - hero:GetPhysicalArmorReduction()
					local origdmg = dmg/dmgmulthero
					local dmgmultattacker = 100 - attacker:GetPhysicalArmorReduction()
					dmgreturn = origdmg*dmgmultattacker
				end
				ApplyDamage({victim = attacker, attacker = hero, damage = dmgreturn/get_aether_multiplier(hero), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			elseif dmgtype == DAMAGE_TYPE_MAGICAL then
				local armorhero = hero:GetMagicalArmorValue()
				local armorattacker = attacker:GetMagicalArmorValue()
				local dmgreturn = dmg
				if armorhero > armorattacker and not GameRules._NewGamePlus then
					dmgreturn = dmg * (armorattacker/armorhero)
				end
				ApplyDamage({victim = attacker, attacker = hero, damage = dmgreturn/get_aether_multiplier(hero), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			else
				ApplyDamage({victim = attacker, attacker = hero, damage = dmg/get_aether_multiplier(hero), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			end
		end
	end
end
