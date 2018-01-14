item_blade_mail4 = class({})
LinkLuaModifier( "modifier_blade_mail_four", "items/blade_mail/item_blade_mail4.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blade_mail_four_active", "items/blade_mail/item_blade_mail4.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_blade_mail4:PiercesDisableResistance()
    return true
end

function item_blade_mail4:GetIntrinsicModifierName()
	return "modifier_blade_mail_four"
end

function item_blade_mail4:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)

	if caster:HasModifier("modifier_blade_mail_four_active") then
		caster:RemoveModifierByName("modifier_blade_mail_four_active")
	end
	caster:AddNewModifier(caster,self, "modifier_blade_mail_four_active", {Duration = self:GetSpecialValueFor("duration")})
	
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
	local event_data =
	{
		threat = caster:GetThreat(),
		lastHit = caster.lastHit,
		aggro = caster.aggro or 0
	}
	local player = caster:GetPlayerOwner()
	CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )

	self:CD_pure()
	self:StartDelayedCooldown(self:GetSpecialValueFor("duration"))
end

modifier_blade_mail_four = class({})

function modifier_blade_mail_four:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_blade_mail_four:DeclareFunctions(params)
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

function modifier_blade_mail_four:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_blade_mail_four:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_blade_mail_four:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_blade_mail_four:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_blade_mail_four:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_blade_mail_four:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_blade_mail_four:IsHidden()
	return true
end

modifier_blade_mail_four_active = class({})
function modifier_blade_mail_four_active:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "reflect_pct" )
end

function modifier_blade_mail_four_active:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "reflect_pct" )
end

function modifier_blade_mail_four_active:DeclareFunctions(params)
local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_blade_mail_four_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_blade_mail_four_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_blade_mail_four_active:StatusEffectPriority()
	return 10
end

function modifier_blade_mail_four_active:IsBuff()
	return true
end

function modifier_blade_mail_four_active:OnTakeDamage(params)
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
