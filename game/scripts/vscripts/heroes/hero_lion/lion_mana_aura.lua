lion_mana_aura = class({})
LinkLuaModifier( "modifier_lion_mana_aura", "heroes/hero_lion/lion_mana_aura.lua",LUA_MODIFIER_MOTION_NONE )

function lion_mana_aura:GetCooldown(lvl)
	return TernaryOperator( self:GetTalentSpecialValueFor("scepter_cd"), self:GetCaster():HasScepter(), 0 )
end

function lion_mana_aura:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function lion_mana_aura:GetIntrinsicModifierName()
    return "modifier_lion_mana_aura"
end

function lion_mana_aura:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_lion_mana_aura_scepter", {} )
	else
		self:GetCaster():RemoveModifierByName("modifier_lion_mana_aura_scepter")
	end
end

modifier_lion_mana_aura = class({})
function modifier_lion_mana_aura:OnCreated()
    self.manaRegen = self:GetTalentSpecialValueFor("mana_regen")
    self.damage = self:GetTalentSpecialValueFor("curr_mana_death") / 100
    self.radius = self:GetTalentSpecialValueFor("death_radius")
end

function modifier_lion_mana_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH 
    }
    return funcs
end

function modifier_lion_mana_aura:GetModifierTotalPercentageManaRegen()
    return self.manaRegen
end

function modifier_lion_mana_aura:OnDeath(params)
	if params.unit == self:GetParent() then
		local damage = params.unit:GetMana() * self.damage
		local origin = params.unit:GetAbsOrigin()
		local ability = self:GetAbility()
		for _, enemy in ipairs( params.unit:FindEnemyUnitsInRadius( origin, self.radius ) ) do
			ability:DealDamage( params.unit, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		end
		params.unit:EmitSound("Hero_Lion.TauntToHell")
		ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_ABSORIGIN, params.unit, {[0] = origin,
																																									[1] = Vector(self.radius,0,0),
																																									[60] = Vector(255,0,0),
																																									[61] = Vector(1,0,0)})
	end
end

function modifier_lion_mana_aura:IsHidden()
    return true
end


modifier_lion_mana_aura_scepter = class({})
LinkLuaModifier( "modifier_lion_mana_aura_scepter", "heroes/hero_lion/lion_mana_aura.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_lion_mana_aura_scepter:OnCreated()
	if IsServer() then self:StartIntervalThink(0.5) end
end

function modifier_lion_mana_aura_scepter:OnIntervalThink()
	if not self:GetCaster():HasScepter() then self:Destroy() end
end