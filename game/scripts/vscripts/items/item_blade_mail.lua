item_blade_mail2 = class({})
LinkLuaModifier( "modifier_blade_mail", "items/item_blade_mail.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blade_mail_taunt", "items/item_blade_mail.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_blade_mail2:PiercesDisableResistance()
    return true
end

function item_blade_mail2:GetIntrinsicModifierName()
	return "modifier_blade_mail"
end

function item_blade_mail2:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)

	if caster:HasModifier("modifier_blade_mail_taunt") then
		caster:RemoveModifierByName("modifier_blade_mail_taunt")
	end
	caster:AddNewModifier(caster,self, "modifier_blade_mail_taunt", {Duration = self:GetSpecialValueFor("duration")})
	
	if not caster:GetThreat() then caster:SetThreat(0) end
	caster:ModifyThreat(self:GetSpecialValueFor("base_threat"))
	caster.lastHit = GameRules:GetGameTime()
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
    for _,enemy in pairs(enemies) do
        if caster:IsAlive() and enemy then
        	enemy:Taunt(self,caster,self:GetSpecialValueFor("duration"))
			caster:ModifyThreat(self:GetSpecialValueFor("threat_per_enemy"))
        else
            enemy:Stop()
        end
    end

	self:CD_pure()
	self:StartDelayedCooldown(self:GetSpecialValueFor("duration"))
end

item_blade_mail3 = class(item_blade_mail2)
item_blade_mail4 = class(item_blade_mail2)

modifier_blade_mail = class({})

function modifier_blade_mail:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_blade_mail:OnCreated()
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.bonus_stats = self:GetAbility():GetSpecialValueFor("bonus_stats")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_blade_mail:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_blade_mail:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_blade_mail:GetModifierBonusStats_Strength()
	return self.bonus_stats
end

function modifier_blade_mail:GetModifierBonusStats_Intellect()
	return self.bonus_stats
end

function modifier_blade_mail:GetModifierBonusStats_Agility()
	return self.bonus_stats
end

function modifier_blade_mail:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_blade_mail:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_blade_mail:IsHidden()
	return true
end

modifier_blade_mail_taunt = class({})
function modifier_blade_mail_taunt:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "reflect_pct" )
end

function modifier_blade_mail_taunt:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "reflect_pct" )
end

function modifier_blade_mail_taunt:DeclareFunctions(params)
local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_blade_mail_taunt:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_blade_mail_taunt:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_blade_mail_taunt:StatusEffectPriority()
	return 10
end

function modifier_blade_mail_taunt:IsBuff()
	return true
end

function modifier_blade_mail_taunt:OnTakeDamage(params)
    local hero = self:GetParent()
    local dmg = params.damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100

    EmitSoundOn("DOTA_Item.BladeMail.Damage", hero)

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
				self:GetAbility():DealDamage(hero, attacker, dmgreturn/get_aether_multiplier(hero), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
			elseif dmgtype == DAMAGE_TYPE_MAGICAL then
				local armorhero = hero:GetMagicalArmorValue()
				local armorattacker = attacker:GetMagicalArmorValue()
				local dmgreturn = dmg
				if armorhero > armorattacker and not GameRules._NewGamePlus then
					dmgreturn = dmg * (armorattacker/armorhero)
				end
				self:GetAbility():DealDamage(hero, attacker, dmgreturn/get_aether_multiplier(hero), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
			else
				self:GetAbility():DealDamage(hero, attacker, dmgreturn/get_aether_multiplier(hero), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
			end
		end
	end
end
