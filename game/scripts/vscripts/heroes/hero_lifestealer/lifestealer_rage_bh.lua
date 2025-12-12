lifestealer_rage_bh = class({})

function lifestealer_rage_bh:GetCastRange( target, position )
	return self:GetSpecialValueFor("cast_range")
end

function lifestealer_rage_bh:OnSpellStart()
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_LIFESTEALER_RAGE)
	caster:EmitSound("Hero_LifeStealer.Rage")
	local duration = self:GetSpecialValueFor("duration")
	
    caster:AddNewModifier(caster, self, "modifier_lifestealer_rage_bh", {Duration = duration})
	caster:Dispel(caster, true)
	-- infest management
	if caster:HasModifier("modifier_lifestealer_infest_bh") then
		local modifier = caster:FindModifierByName("modifier_lifestealer_infest_bh")
		if modifier then
			local target = modifier.target
			if target and target:IsSameTeam( caster ) then
				target:AddNewModifier(caster, self, "modifier_lifestealer_rage_bh", {Duration = duration})
			end
		end
	end
end

modifier_lifestealer_rage_bh = class({})
LinkLuaModifier( "modifier_lifestealer_rage_bh", "heroes/hero_lifestealer/lifestealer_rage_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lifestealer_rage_bh:OnCreated(table)
	self:OnRefresh()
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloch", self:GetParent():GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		-- self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_lifestealer_rage_bh:OnRefresh()
	self.ms = self:GetSpecialValueFor("bonus_movespeed")
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_lifestealer_rage_bh:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS 
            }
    return funcs
end

function modifier_lifestealer_rage_bh:CheckState()
    local state = { [MODIFIER_STATE_DEBUFF_IMMUNE] = true}
    return state
end

function modifier_lifestealer_rage_bh:GetModifierMagicalResistanceBonus()
    return 80
end

function modifier_lifestealer_rage_bh:GetModifierMoveSpeedBonus_Percentage()
    return self.ms
end

function modifier_lifestealer_rage_bh:GetModifierPhysicalArmorBonus()
    return self.armor
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