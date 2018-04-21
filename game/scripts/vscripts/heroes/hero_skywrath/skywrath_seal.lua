skywrath_seal = class({})
LinkLuaModifier( "modifier_skywrath_seal","heroes/hero_skywrath/skywrath_seal.lua",LUA_MODIFIER_MOTION_NONE )

function skywrath_seal:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_skywrath_seal_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_seal_2") end
    return cooldown
end

function skywrath_seal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_SkywrathMage.AncientSeal.Target", target)

	target:AddNewModifier(caster, self, "modifier_skywrath_seal", {Duration = self:GetTalentSpecialValueFor("duration")})

	if caster:HasScepter() then
        local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTrueCastRange())
        for _,enemy in pairs(enemies) do
            if enemy ~= target then
            	EmitSoundOn("Hero_SkywrathMage.AncientSeal.Target", enemy)
                enemy:AddNewModifier(caster, self, "modifier_skywrath_seal", {Duration = self:GetTalentSpecialValueFor("duration")})
                break
            end
        end
    end

	self:StartDelayedCooldown(self:GetTalentSpecialValueFor("duration"))
end

modifier_skywrath_seal = class({})
function modifier_skywrath_seal:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
   		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
   		ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_skywrath_seal:OnRemoved()
	if IsServer() then
		ParticleManager:ClearParticle(self.nfx)
	end
end

function modifier_skywrath_seal:CheckState()
	local state = { [MODIFIER_STATE_SILENCED] = true}
	return state
end

function modifier_skywrath_seal:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
    return funcs
end

function modifier_skywrath_seal:GetModifierMagicalResistanceBonus()
    return self:GetTalentSpecialValueFor("mr_reduc")
end

function modifier_skywrath_seal:IsDebuff()
    return true
end