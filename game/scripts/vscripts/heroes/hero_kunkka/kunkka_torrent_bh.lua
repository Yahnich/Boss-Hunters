kunkka_torrent_bh = class({})
LinkLuaModifier("modifier_kunkka_torrent_bh", "heroes/hero_kunkka/kunkka_torrent_bh", LUA_MODIFIER_MOTION_NONE)

function kunkka_torrent_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function kunkka_torrent_bh:IsStealable()
    return true
end

function kunkka_torrent_bh:IsHiddenWhenStolen()
    return false
end

function kunkka_torrent_bh:OnSpellStart()
    local point = self:GetCursorPosition()
	
	self:CreateTorrent(point)
end

function kunkka_torrent_bh:CreateTorrent(position)
	local caster = self:GetCaster()
	EmitSoundOnLocationWithCaster(position, "Ability.pre.Torrent", caster)

    local bubbles = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(bubbles, 0, position)
	local slow = self:GetTalentSpecialValueFor("slow_duration")
    Timers:CreateTimer(self:GetTalentSpecialValueFor("delay"), function()
        ParticleManager:ClearParticle(bubbles)
        StopSoundOn("Ability.pre.Torrent", caster)
        EmitSoundOnLocationWithCaster(position, "Ability.Torrent", caster)
        ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_POINT, caster, {[0]=position})
        local enemies = caster:FindEnemyUnitsInRadius(position, self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            enemy:ApplyKnockBack(enemy:GetAbsOrigin(), self:GetTalentSpecialValueFor("stun_duration"), self:GetTalentSpecialValueFor("stun_duration"), 0, 350, caster, self)
            enemy:AddNewModifier(caster, self, "modifier_kunkka_torrent_bh", {Duration = slow})
            self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"))
        end
		local allies = caster:FindFriendlyUnitsInRadius(position, self:GetTalentSpecialValueFor("radius"))
		for _,ally in pairs(allies) do
            ally:AddNewModifier(caster, self, "modifier_in_water", {Duration = slow})
        end
    end)
end

modifier_kunkka_torrent_bh = class({})
function modifier_kunkka_torrent_bh:IsDebuff() return true end

function modifier_kunkka_torrent_bh:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_kunkka_torrent_bh:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("movespeed_bonus")
end

function modifier_kunkka_torrent_bh:GetEffectName()
    return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_kunkka_torrent_bh:GetStatusEffectName()
    return "particles/status_fx/status_effect_gush.vpcf"
end

function modifier_kunkka_torrent_bh:StatusEffectPriority()
    return 10
end