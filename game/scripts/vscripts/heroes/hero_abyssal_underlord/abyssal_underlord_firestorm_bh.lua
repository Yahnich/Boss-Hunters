abyssal_underlord_firestorm_bh = class({})
LinkLuaModifier( "modifier_abyssal_underlord_firestorm_bh", "heroes/hero_abyssal_underlord/abyssal_underlord_firestorm_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_abyssal_underlord_firestorm_bh_burn", "heroes/hero_abyssal_underlord/abyssal_underlord_firestorm_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function abyssal_underlord_firestorm_bh:IsStealable()
    return true
end

function abyssal_underlord_firestorm_bh:IsHiddenWhenStolen()
    return false
end

function abyssal_underlord_firestorm_bh:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function abyssal_underlord_firestorm_bh:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Start")
    local radius = self:GetTalentSpecialValueFor("radius")

    self.nfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(self.nfx, 0, point)
                ParticleManager:SetParticleControl(self.nfx, 1, Vector(radius, radius, 1))

    return true
end

function abyssal_underlord_firestorm_bh:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle( self.nfx )
	self:GetCaster():StopSound("Hero_AbyssalUnderlord.Firestorm.Start")
end

function abyssal_underlord_firestorm_bh:OnSpellStart()
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()
	
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Cast")
	if self.nfx then
		ParticleManager:ClearParticle( self.nfx )
	end
	local duration = self:GetTalentSpecialValueFor("wave_count") * self:GetTalentSpecialValueFor("wave_interval")
    CreateModifierThinker(caster, self, "modifier_abyssal_underlord_firestorm_bh", {Duration = duration + 1}, point, caster:GetTeam(), false)
end

modifier_abyssal_underlord_firestorm_bh = class({})
function modifier_abyssal_underlord_firestorm_bh:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(1)
    end
end

function modifier_abyssal_underlord_firestorm_bh:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local point = parent:GetAbsOrigin()

    local damage = self:GetTalentSpecialValueFor("wave_damage")
    local radius = self:GetTalentSpecialValueFor("radius")

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(nfx, 0, point)
                ParticleManager:SetParticleControl(nfx, 4, Vector(radius, radius, radius))
                ParticleManager:ReleaseParticleIndex(nfx)
	parent:EmitSound("Hero_AbyssalUnderlord.Firestorm")
    local enemies = caster:FindEnemyUnitsInRadius(point, radius)
    for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self:GetAbility() ) then
			enemy:AddNewModifier(caster, ability, "modifier_abyssal_underlord_firestorm_bh_burn", {Duration = self:GetTalentSpecialValueFor("burn_damage")})
			ability:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			enemy:EmitSound("Hero_AbyssalUnderlord.Firestorm.Target")
		end
    end
	AddFOWViewer( DOTA_TEAM_GOODGUYS, parent:GetAbsOrigin(), radius, 1, false )
end


modifier_abyssal_underlord_firestorm_bh_burn = class({})

function modifier_abyssal_underlord_firestorm_bh_burn:OnCreated(kv)
	self.miss = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_firestorm_2", "miss") * (-1)
	self.blind = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_firestorm_2", "blind") * (-1)
    if IsServer() then
        self:StartIntervalThink(self:GetTalentSpecialValueFor("burn_interval"))
    end
end

function modifier_abyssal_underlord_firestorm_bh_burn:OnRefresh(kv)
	self.miss = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_firestorm_2", "miss") * (-1)
	self.blind = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_firestorm_2", "blind") * (-1)
end


function modifier_abyssal_underlord_firestorm_bh_burn:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local damage = self:GetParent():GetMaxHealth() * self:GetTalentSpecialValueFor("burn_damage")/100
	
    self:GetAbility():DealDamage(caster, parent, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_abyssal_underlord_firestorm_bh_burn:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE, MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE}
end

function modifier_abyssal_underlord_firestorm_bh_burn:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_abyssal_underlord_firestorm_bh_burn:GetBonusVisionPercentage()
	return self.blind
end

function modifier_abyssal_underlord_firestorm_bh_burn:GetEffectName()
    return "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf"
end

function modifier_abyssal_underlord_firestorm_bh_burn:IsDebuff()
    return true
end