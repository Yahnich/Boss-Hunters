pudge_rot_lua = class({})
LinkLuaModifier( "modifier_rot_lua", "heroes/hero_pudge/pudge_rot_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rot_lua_effect", "heroes/hero_pudge/pudge_rot_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function pudge_rot_lua:OnToggle()
	-- Apply the rot modifier if the toggle is on
	if self:GetToggleState() then

		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rot_lua", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		-- Remove it if it is off
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_rot_lua" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

modifier_rot_lua = class(toggleModifierBaseClass)
function modifier_rot_lua:OnCreated(table)
    if IsServer() then
    	local radius = self:GetTalentSpecialValueFor("radius")
    	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    	ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    	ParticleManager:SetParticleControl(self.nfx, 1, Vector(radius,radius,radius))
    	self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
		EmitSoundOn("Hero_Pudge.Rot", self:GetParent())
    end
end

function modifier_rot_lua:OnRemoved()
    if IsServer() then
    	StopSoundOn("Hero_Pudge.Rot", self:GetParent())
    	ParticleManager:ClearParticle(self.nfx)
    end
end

function modifier_rot_lua:OnIntervalThink()
    if IsServer() then
    	local damage = self:GetTalentSpecialValueFor("damage") + self:GetTalentSpecialValueFor("damage_str")/100 * self:GetCaster():GetStrength()
    	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage*0.2, {}, 0)
    end
end

function modifier_rot_lua:IsAura()
    return true
end

function modifier_rot_lua:GetAuraDuration()
    return 0.5
end

function modifier_rot_lua:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_rot_lua:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_rot_lua:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_rot_lua:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_rot_lua:GetModifierAura()
    return "modifier_rot_lua_effect"
end

modifier_rot_lua_effect = class({})
function modifier_rot_lua_effect:OnCreated(table)
    if IsServer() then
    	self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
    end
end

function modifier_rot_lua_effect:OnIntervalThink()
    if IsServer() then
    	local damage = self:GetTalentSpecialValueFor("damage") + self:GetTalentSpecialValueFor("damage_str")/100 * self:GetCaster():GetStrength()
    	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage*0.2, {}, 0)
    end
end

function modifier_rot_lua_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_rot_lua_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow")
end

function modifier_rot_lua_effect:GetEffectName()
    return "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf"
end