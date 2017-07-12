ifrit_inferno = class({})

function ifrit_inferno:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_inferno_kindled"
	else
		return "custom/ifrit_inferno"
	end
end

function ifrit_inferno:GetAOERadius()
	return self:GetSpecialValueFor("inferno_radius")
end

function ifrit_inferno:OnSpellStart()
	if self:GetCaster():HasTalent("ifrit_inferno_talent_1") and self:GetCursorTarget() then
		CreateModifierThinker( self:GetCaster(), self, "modifier_ifrit_inferno_thinker", {duration = self:GetTalentSpecialValueFor("inferno_duration"), kindled = tostring(self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active")), target = self:GetCursorTarget():entindex()}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
	else
		CreateModifierThinker( self:GetCaster(), self, "modifier_ifrit_inferno_thinker", {duration = self:GetTalentSpecialValueFor("inferno_duration"), kindled = tostring(self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active"))}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
	end	
end


modifier_ifrit_inferno_thinker = class({})
LinkLuaModifier( "modifier_ifrit_inferno_thinker", "heroes/ifrit/ifrit_inferno.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_ifrit_inferno_thinker:OnCreated(kv)
		self.kindled = toboolean(kv.kindled)
		self.damage = self:GetAbility():GetTalentSpecialValueFor("inferno_damage") + (self:GetCaster().selfImmolationDamageBonus or 0)
		self.radius = self:GetAbility():GetTalentSpecialValueFor("inferno_radius")
		if kv.target then
			self.target = EntIndexToHScript(kv.target)
		end
		
		self:StartIntervalThink(FrameTime())
		
		self.internalTimer = 0
		
		EmitSoundOn("Hero_EmberSpirit.FlameGuard.Cast", self:GetParent())
		EmitSoundOn("Hero_EmberSpirit.FlameGuard.Loop", self:GetParent())
		
		self.nFXIndex = ParticleManager:CreateParticle( "particles/heroes/phoenix/phoenix_inferno.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetOrigin() )
	end
	
	function modifier_ifrit_inferno_thinker:OnDestroy()
		ParticleManager:DestroyParticle(self.nFXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.nFXIndex)
		StopSoundOn("Hero_EmberSpirit.FlameGuard.Loop", self:GetParent())
		UTIL_Remove(self:GetParent())
	end
	
	function modifier_ifrit_inferno_thinker:OnIntervalThink()
		if self.target and not self.target:IsNull() and self.target:IsAlive() then
			self:GetParent():SetAbsOrigin( self.target:GetAbsOrigin() )
		end
		self.internalTimer = self.internalTimer + FrameTime()
		if self.internalTimer >= 1 then
			self.internalTimer = 0
			local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius, {})
			for _, enemy in pairs(enemies) do
				self:GetAbility():DealDamage(self:GetCaster(), enemy, self.damage)
				if self.kindled then
					local duration = self:GetAbility():GetTalentSpecialValueFor("kindled_burn_duration")
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ifrit_inferno_fire_debuff", {duration = duration})
				end
			end
		end
	end
end


LinkLuaModifier( "modifier_ifrit_inferno_fire_debuff", "heroes/ifrit/ifrit_inferno.lua", LUA_MODIFIER_MOTION_NONE )
modifier_ifrit_inferno_fire_debuff = class({})

function modifier_ifrit_inferno_fire_debuff:OnCreated()
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("burn_dot")
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_ifrit_inferno_fire_debuff:OnRefresh()
	local addedDamage = self:GetAbility():GetTalentSpecialValueFor("burn_dot")
	if self:GetCaster():HasScepter() then addedDamage = addedDamage * 2 end
	self.damage_over_time = self.damage_over_time + addedDamage
end

function modifier_ifrit_inferno_fire_debuff:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_inferno_fire_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_inferno_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_inferno_fire_debuff:IsFireDebuff()
	return true
end