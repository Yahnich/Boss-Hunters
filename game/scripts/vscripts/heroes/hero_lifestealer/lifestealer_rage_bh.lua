lifestealer_rage_bh = class({})
LinkLuaModifier( "modifier_lifestealer_rage_bh", "heroes/hero_lifestealer/lifestealer_rage_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function lifestealer_rage_bh:OnSpellStart()
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_LIFESTEALER_RAGE)
    caster:AddNewModifier(caster, self, "modifier_lifestealer_rage_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_lifestealer_rage_bh = class({})

if IsServer() then
	function modifier_lifestealer_rage_bh:OnCreated(table)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloch", self:GetParent():GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		self:GetAbility():StartDelayedCooldown()
	end

	function modifier_lifestealer_rage_bh:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_lifestealer_rage_bh:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_lifestealer_rage_bh:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            }
    return funcs
end

function modifier_lifestealer_rage_bh:CheckState()
    local state = { [MODIFIER_STATE_MAGIC_IMMUNE] = true}
    return state
end

function modifier_lifestealer_rage_bh:GetModifierMagicalResistanceBonus()
    return 1000
end

function modifier_lifestealer_rage_bh:GetModifierAttackSpeedBonus_Constant()
    return self:GetTalentSpecialValueFor("attack_speed_bonus")
end

function modifier_lifestealer_rage_bh:IsHidden()
    return false
end

function modifier_lifestealer_rage_bh:IsDebuff()
    return false
end

function modifier_lifestealer_rage_bh:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_lifestealer_rage_bh:StatusEffectPriority()
    return 10
end