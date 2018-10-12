riki_smoke_bomb = class({})
LinkLuaModifier( "modifier_smoke_bomb", "heroes/hero_riki/riki_smoke_bomb.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_smoke_bomb_enemy", "heroes/hero_riki/riki_smoke_bomb.lua" ,LUA_MODIFIER_MOTION_NONE )

function riki_smoke_bomb:IsStealable()
    return true
end

function riki_smoke_bomb:IsHiddenWhenStolen()
    return false
end

function riki_smoke_bomb:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    if caster:HasTalent("special_bonus_unique_riki_smoke_bomb_2") then
		local damage = self:GetTalentSpecialValueFor("damage")
		local dmgMultiplier = caster:FindTalentValue("special_bonus_unique_riki_smoke_bomb_2")
        local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius"), {})
        for _,enemy in pairs(enemies) do
            self:DealDamage(caster, enemy, damage * dmgMultiplier, {}, 0)
        end
    end

    CreateModifierThinker(caster, self, "modifier_smoke_bomb", {Duration = self:GetTalentSpecialValueFor("duration")}, point, caster:GetTeam(), false)
end

modifier_smoke_bomb = class({})
function modifier_smoke_bomb:OnCreated(table)
    if IsServer() then
        EmitSoundOn("Hero_Riki.Smoke_Screen", self:GetParent())

        local radius = self:GetTalentSpecialValueFor("radius")
        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_smokebomb.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.nfx, 1, Vector(radius, radius, radius))

        self:StartIntervalThink(1.0)
    end
end

function modifier_smoke_bomb:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	local hasTalent1 = self:GetCaster():HasTalent("special_bonus_unique_riki_smoke_bomb_1")
	local damage = self:GetTalentSpecialValueFor("damage")
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_smoke_bomb_enemy", {Duration = 1.0})
		if hasTalent1 then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silence", {Duration = 1.0})
		end
        self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
    end
end

function modifier_smoke_bomb:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_Riki.Smoke_Screen", self:GetParent())
        ParticleManager:DestroyParticle(self.nfx, false)
    end
end

modifier_smoke_bomb_enemy = class({})

function modifier_smoke_bomb_enemy:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MISS_PERCENTAGE
    }   
    return funcs
end

function modifier_smoke_bomb_enemy:GetModifierMiss_Percentage()
    return self:GetTalentSpecialValueFor("miss_rate")
end

function modifier_smoke_bomb_enemy:IsDebuff()
    return true
end

function modifier_smoke_bomb_enemy:GetEffectName()
	if self:GetCaster():HasTalent("special_bonus_unique_riki_smoke_bomb_1") then
		return "particles/generic_gameplay/generic_silence.vpcf"
	end
end

function modifier_smoke_bomb_enemy:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end