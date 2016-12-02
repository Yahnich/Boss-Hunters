modifier_mage_rage_leech = class({})


function modifier_mage_rage_leech:OnCreated( kv )
	self.leech = self:GetAbility():GetSpecialValueFor( "leech" ) / 100
	self.base = self:GetAbility():GetSpecialValueFor( "base" )
	self.tobank = self:GetAbility():GetSpecialValueFor( "bank_pct" ) / 100
end

function modifier_mage_rage_leech:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_mage_rage_leech:OnRefresh( kv )
	self.leech = self:GetAbility():GetSpecialValueFor( "leech" ) / 100
	self.base = self:GetAbility():GetSpecialValueFor( "base" )
	self.tobank = self:GetAbility():GetSpecialValueFor( "bank_pct" ) / 100
end

--------------------------------------------------------------------------------

function modifier_mage_rage_leech:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_mage_rage_leech:OnTakeDamage(params)
    local hero = self:GetCaster()
    local dmg = params.damage
    if params.inflictor and params.inflictor ~= self:GetAbility() then
		hero.rage = hero.rage + dmg*self.leech*(1-self.tobank)
		hero.bank = hero.bank + dmg*self.leech*self.tobank
    end
end

function modifier_mage_rage_leech:OnAbilityExecuted(params)
    local hero = self:GetCaster()
	if not (params.ability:GetCooldown(-1) <= 0 or params.ability:GetName() == "item_shadow_amulet") then
		hero.rage = hero.rage + self.base*(1-self.tobank)
		hero.bank = hero.bank + self.base*self.tobank
	end
end


