winterw_winters_kiss = class({})
LinkLuaModifier( "modifier_winters_kiss", "heroes/hero_ww/winterw_winters_kiss.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_winters_kiss_enemy", "heroes/hero_ww/winterw_winters_kiss.lua" ,LUA_MODIFIER_MOTION_NONE )

function winterw_winters_kiss:IsStealable()
    return true
end

function winterw_winters_kiss:IsHiddenWhenStolen()
    return false
end

function winterw_winters_kiss:PiercesDisableResistance()
    return true
end

function winterw_winters_kiss:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Winter_Wyvern.WintersCurse.Cast", caster)
	EmitSoundOn("Hero_Winter_Wyvern.WintersCurse.Target", target)

    local startFX = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_ground.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(startFX, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(startFX, 2, Vector(self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius")))
    ParticleManager:ReleaseParticleIndex(startFX)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_ring_rope.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius")))
    ParticleManager:ReleaseParticleIndex(nfx)
	if target:TriggerSpellAbsorb( self ) then return end
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
    for _,enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_winters_kiss_enemy") then
            enemy:FindModifierByName("modifier_winters_kiss_enemy"):Destroy()
        end
    end
	target:AddNewModifier(caster, self, "modifier_winters_kiss", {Duration = self:GetSpecialValueFor("duration")})
    -- self:StartDelayedCooldown(self:GetSpecialValueFor("duration"))
end

modifier_winters_kiss = ({})
function modifier_winters_kiss:OnCreated(table)
    if self:GetCaster():HasTalent("special_bonus_unique_winterw_winters_kiss_2") then
        self.damageReduc = self:GetCaster():FindTalentValue("special_bonus_unique_winterw_winters_kiss_2")
    else
        self.damageReduc = 0
    end
    if IsServer() then
    	self:StartIntervalThink(FrameTime())
    end
end

function modifier_winters_kiss:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_winters_kiss") then
        local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
        for _,enemy in pairs(enemies) do
            if enemy ~= self:GetParent() then
                enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_winters_kiss_enemy", {duration = self:GetRemainingTime()})
            end
        end
    end
end

function modifier_winters_kiss:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_FROZEN] = true,
                    [MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
	return state
end

function modifier_winters_kiss:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_winters_kiss:GetModifierIncomingDamage_Percentage(params)
    return self.damageReduc
end

function modifier_winters_kiss:IsDebuff()
    return true
end

function modifier_winters_kiss:GetEffectName()
    return "particles/units/heroes/hero_winterw/winterw_winters_kiss_debuff.vpcf"
end

function modifier_winters_kiss:GetStatusEffectName()
    return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf"
end

function modifier_winters_kiss:StatusEffectPriority()
    return 10
end

modifier_winters_kiss_enemy = ({})
function modifier_winters_kiss_enemy:DeclareFunctions()
    local funcs = {
        
    }
    return funcs
end
if IsServer() then
	function modifier_winters_kiss_enemy:OnCreated()
		local parent = self:GetParent()
		parent:Stop()
		parent:Hold()
		parent:Interrupt()
		local target = self:GetCaster()
		ExecuteOrderFromTable({
			UnitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		})
	end
	
	function modifier_winters_kiss_enemy:OnDestroy()
		local parent = self:GetParent()
		parent:Stop()
		parent:Hold()
		parent:Interrupt()
	end
end

function modifier_winters_kiss_enemy:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_winters_kiss_enemy:GetModifierAttackSpeedBonus_Constant()
    return self:GetSpecialValueFor("bonus_as")
end

function modifier_winters_kiss_enemy:GetTauntTarget()
    return self:GetCaster()
end

function modifier_winters_kiss_enemy:GetEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_buff.vpcf"
end

function modifier_winters_kiss_enemy:GetStatusEffectName()
    return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf"
end

function modifier_winters_kiss_enemy:StatusEffectPriority()
    return 10
end

function modifier_winters_kiss_enemy:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	return state
end