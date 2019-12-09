boss_lifestealer_bloodfrenzy = class({})

function boss_lifestealer_bloodfrenzy:OnSpellStart()
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_LIFESTEALER_RAGE)
	caster:EmitSound("Hero_LifeStealer.Rage")
	caster:Dispel(caster, true)
    caster:AddNewModifier(caster, self, "modifier_boss_lifestealer_bloodfrenzy", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_boss_lifestealer_bloodfrenzy = class({})
LinkLuaModifier( "modifier_boss_lifestealer_bloodfrenzy", "bosses/boss_lifestealer/boss_lifestealer_bloodfrenzy.lua", LUA_MODIFIER_MOTION_NONE )


function modifier_boss_lifestealer_bloodfrenzy:OnCreated(table)
	self.mr = self:GetTalentSpecialValueFor("magic_resist")
	self.sr = self:GetTalentSpecialValueFor("status_resist")
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloch", self:GetParent():GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_boss_lifestealer_bloodfrenzy:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
            }
    return funcs
end

function modifier_boss_lifestealer_bloodfrenzy:GetModifierMagicalResistanceBonus()
    return self.mr
end

function modifier_boss_lifestealer_bloodfrenzy:GetModifierStatusResistanceStacking()
    return self.sr
end

function modifier_boss_lifestealer_bloodfrenzy:GetModifierMoveSpeedBonus_Percentage()
    return self.ms
end

function modifier_boss_lifestealer_bloodfrenzy:IsHidden()
    return false
end

function modifier_boss_lifestealer_bloodfrenzy:IsDebuff()
    return false
end

function modifier_boss_lifestealer_bloodfrenzy:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_boss_lifestealer_bloodfrenzy:StatusEffectPriority()
    return 10
end