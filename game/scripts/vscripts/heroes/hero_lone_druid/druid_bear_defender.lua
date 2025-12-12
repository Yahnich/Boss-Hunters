druid_bear_defender = class({})
LinkLuaModifier("modifier_druid_bear_defender", "heroes/hero_lone_druid/druid_bear_defender", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_druid_bear_defender_druid", "heroes/hero_lone_druid/druid_bear_defender", LUA_MODIFIER_MOTION_NONE)

function druid_bear_defender:IsStealable()
    return false
end

function druid_bear_defender:IsHiddenWhenStolen()
    return false
end

function druid_bear_defender:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

function druid_bear_defender:GetIntrinsicModifierName()
    return "modifier_druid_bear_defender"
end

modifier_druid_bear_defender = class({})
function modifier_druid_bear_defender:IsAura()
    return true
end

function modifier_druid_bear_defender:GetAuraDuration()
    return 0.5
end

function modifier_druid_bear_defender:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_druid_bear_defender:GetAuraEntityReject(hEntity)
	local parent = self:GetParent()
	local owner = parent:GetOwner()
	if parent:PassivesDisabled() then
	    return true
	else
		if hEntity ~= owner then
	    	return true
	    end
	end
end

function modifier_druid_bear_defender:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_druid_bear_defender:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_druid_bear_defender:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_druid_bear_defender:GetModifierAura()
    return "modifier_druid_bear_defender_druid"
end

function modifier_druid_bear_defender:IsHidden()
    return true
end

function modifier_druid_bear_defender:IsPurgable()
    return false
end

function modifier_druid_bear_defender:IsPurgeException()
    return false
end

modifier_druid_bear_defender_druid = class({})
function modifier_druid_bear_defender_druid:OnCreated(table)
	self.damage_reduce = self:GetSpecialValueFor("percent_shared")

	self:StartIntervalThink(0.1)
end

function modifier_druid_bear_defender_druid:OnIntervalThink()
	if IsServer() then
		if not self:GetCaster() then
			self:Destroy()
		end
	end
end

function modifier_druid_bear_defender_druid:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
	return funcs
end

function modifier_druid_bear_defender_druid:GetModifierIncomingDamage_Percentage(params)
	if IsServer() then
		if params.target == self:GetParent() then
			local caster = self:GetCaster()

			local damage = params.damage
			local damage_og = params.original_damage

			local difference = damage_og - damage

			caster:ModifyHealth(caster:GetHealth() - difference, self:GetAbility(), true, 0)
		end
	end
	return self.damage_reduce
end

function modifier_druid_bear_defender_druid:GetTexture()
    return "lone_druid_spirit_bear_defender"
end

function modifier_druid_bear_defender_druid:IsDebuff()
    return false
end