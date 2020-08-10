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
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.damage_increase = self:GetTalentSpecialValueFor("damage_increase")
		self.tick = self:GetTalentSpecialValueFor("tick_rate")
    	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    	ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    	ParticleManager:SetParticleControl(self.nfx, 1, Vector(radius,radius,radius))
    	self:StartIntervalThink(self.tick)
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
		self.damage = self.damage + self.damage_increase * self.tick
    	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage * self.tick, {}, 0)
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
		self.tick = self:GetTalentSpecialValueFor("tick_rate")
		self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_pudge_rot_lua_1")
		self.talent1Trigger = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_rot_lua_1")
    	self:StartIntervalThink(self.tick)
    end
end

function modifier_rot_lua_effect:OnIntervalThink()
    if IsServer() then
		if self:GetCaster():FindModifierByName("modifier_rot_lua") then
			self.damage = self:GetCaster():FindModifierByName("modifier_rot_lua").damage
		end
    	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage*self.tick, {}, 0)
    end
end

function modifier_rot_lua_effect:CheckState()
	if self.talent1 and not self.talent1Triggered then
		if GameRules:GetGameTime() - self:GetLastAppliedTime( ) > self.talent1Trigger then
			local pID = ParticleManager:CreateParticle( "particles/units/heroes/hero_elder_titan/elder_titan_scepter_disarm.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
			self:AddOverHeadEffect(pID) 
			self.talent1Triggered = true
		end
	elseif self.talent1Triggered then 
		return {[MODIFIER_STATE_DISARMED] = true}
	end
end

function modifier_rot_lua_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH 
    }
    return funcs
end

function modifier_rot_lua_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow")
end

function modifier_rot_lua_effect:OnDeath(params)
    if params.unit == self:GetParent() then
		local stacks = self:GetTalentSpecialValueFor("heap_stacks")
		if self:GetParent():IsMinion() then
			stacks = self:GetTalentSpecialValueFor("minion_stacks")
		end
		local skinHeap = self:GetCaster():FindAbilityByName("pudge_flesh_heap_lua")
		if skinHeap then
			skinHeap:AddSkinHeap(stacks)
		end
	end
end

function modifier_rot_lua_effect:GetEffectName()
    return "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf"
end