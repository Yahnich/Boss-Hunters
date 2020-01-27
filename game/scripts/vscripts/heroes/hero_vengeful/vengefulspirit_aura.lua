vengefulspirit_aura = class({})
LinkLuaModifier( "modifier_vengefulspirit_aura", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vengefulspirit_aura_buff", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vengefulspirit_aura_illusion", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )

function vengefulspirit_aura:GetIntrinsicModifierName()
	return "modifier_vengefulspirit_aura"
end

modifier_vengefulspirit_aura = class({})
function modifier_vengefulspirit_aura:IsAura()
    return true
end

function modifier_vengefulspirit_aura:GetAuraDuration()
    return 0.5
end

function modifier_vengefulspirit_aura:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_vengefulspirit_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_vengefulspirit_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_vengefulspirit_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_vengefulspirit_aura:GetModifierAura()
    return "modifier_vengefulspirit_aura_buff"
end

function modifier_vengefulspirit_aura:IsAuraActiveOnDeath()
    return false
end

function modifier_vengefulspirit_aura:IsHidden()
    return true
end

modifier_vengefulspirit_aura_buff = class({})
function modifier_vengefulspirit_aura_buff:OnCreated(table)
    self.bonus_damage = self:GetTalentSpecialValueFor("bonus_damage")
    if self:GetCaster():HasScepter() then
        self.bonus_damage = self:GetTalentSpecialValueFor("scepter_bonus_damage")
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_vengefulspirit_aura_buff:OnRefresh(table)
    self.bonus_damage = self:GetTalentSpecialValueFor("bonus_damage")
    if self:GetCaster():HasScepter() then
        self.bonus_damage = self:GetTalentSpecialValueFor("scepter_bonus_damage")
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_vengefulspirit_aura_buff:OnIntervalThink()
    self.bonus_damage = self:GetTalentSpecialValueFor("bonus_damage")
    if self:GetCaster():HasScepter() then
        self.bonus_damage = self:GetTalentSpecialValueFor("scepter_bonus_damage")
    end
end

function modifier_vengefulspirit_aura_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_vengefulspirit_aura_buff:GetModifierDamageOutgoing_Percentage()
    return self.bonus_damage
end

function modifier_vengefulspirit_aura_buff:OnDeath(params)
    if IsServer() then
    	if params.unit == self:GetParent() and params.unit:IsHero() and not params.unit:IsIllusion() then
            local damage = self:GetTalentSpecialValueFor("image_damage_out")
            if self:GetCaster():HasScepter() then
                damage = self:GetTalentSpecialValueFor("scepter_image_damage_out")
            end
			local callback = (function( illusion, self, caster, ability )
				illusion:AddNewModifier(caster, ability, "modifier_vengefulspirit_aura_illusion", {})
			end)
    		self:GetParent():ConjureImage( self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("image_duration"), damage, self:GetTalentSpecialValueFor("image_damage_in"), nil, self, true, self:GetCaster(), callback )
    		
    	end
    end
end

modifier_vengefulspirit_aura_illusion = class({})
function modifier_vengefulspirit_aura_illusion:CheckState()
	local state = {    [MODIFIER_STATE_INVULNERABLE]=true,
					   [MODIFIER_STATE_UNSELECTABLE]=true,
					   [MODIFIER_STATE_UNTARGETABLE]=true,
					   [MODIFIER_STATE_ATTACK_IMMUNE]=true,
					   [MODIFIER_STATE_MAGIC_IMMUNE]=true,
					   [MODIFIER_STATE_COMMAND_RESTRICTED]=true,
					   [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]=true,
                       [MODIFIER_STATE_NO_HEALTH_BAR]=true,
					}
	return state
end

function modifier_vengefulspirit_aura_illusion:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_venge_aura_cast.vpcf"
end