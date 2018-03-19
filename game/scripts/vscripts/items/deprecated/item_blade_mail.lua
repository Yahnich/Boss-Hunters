item_blade_mail2 = class({})

function item_blade_mail2:GetIntrinsicModifierName()
	return "modifier_blade_mail"
end

function item_blade_mail2:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)

	caster:AddNewModifier(caster,self, "modifier_blade_mail_taunt", {Duration = self:GetSpecialValueFor("duration")})
	
	if not caster:GetThreat() then caster:SetThreat(0) end
	caster:ModifyThreat(self:GetSpecialValueFor("base_threat"))
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
    for _,enemy in pairs(enemies) do
        if caster:IsAlive() and enemy then
        	enemy:Taunt(self,caster,self:GetSpecialValueFor("duration"))
			caster:ModifyThreat(self:GetSpecialValueFor("threat_per_enemy"))
        else
            enemy:Stop()
        end
    end
end

LinkLuaModifier( "modifier_blade_mail", "items/item_blade_mail.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_blade_mail = class({})

function modifier_blade_mail:OnCreated()
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.bonus_stats = self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_blade_mail:DeclareFunctions(params)
local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_blade_mail:OnTakeDamage(params)
    local hero = self:GetParent()
    local dmg = params.original_damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100
	if hero:HasModifier("modifier_blade_mail_taunt") then
		reflectpct = self.activereflect / 100
		EmitSoundOn("DOTA_Item.BladeMail.Damage", hero)
	end

	if attacker:GetTeamNumber()  ~= hero:GetTeamNumber() then
		if params.unit == hero then
			dmg = dmg * reflectpct
			self:GetAbility():DealDamage( hero, attacker, dmg )
		end
	end
end

function modifier_blade_mail:IsHidden()
	return true
end

LinkLuaModifier( "modifier_blade_mail_taunt", "items/item_blade_mail.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_blade_mail_taunt = class({})