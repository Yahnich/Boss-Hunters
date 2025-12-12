juggernaut_momentum_strike = class({})

function juggernaut_momentum_strike:GetBehavior()
	if self:GetCaster():HasModifier("modifier_juggernaut_momentum_strike_momentum") or self:GetCaster():HasTalent("special_bonus_unique_juggernaut_momentum_strike_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function juggernaut_momentum_strike:GetCastRange()
	return self:GetSpecialValueFor("jump_distance")
end
	
function juggernaut_momentum_strike:GetCooldown()
	if self:GetCaster():HasTalent("special_bonus_unique_juggernaut_momentum_strike_1") then
		return  self:GetCaster():FindTalentValue("special_bonus_unique_juggernaut_momentum_strike_1", "cd")
	end
end

function juggernaut_momentum_strike:GetIntrinsicModifierName()
	return "modifier_juggernaut_momentum_strike_passive"
end

function juggernaut_momentum_strike:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local speed = self:GetSpecialValueFor("jump_speed")
	local distance = CalculateDistance( caster, position )
	
	caster:AddNewModifier( caster, self, "modifier_juggernaut_blade_dance_movement", {duration = distance / speed} )
	local momentum = caster:FindModifierByName( "modifier_juggernaut_momentum_strike_momentum" )
	if momentum then
		momentum:DecrementStackCount()
		self:Refresh()
		if momentum:GetStackCount() == 0 then
			momentum:Destroy()
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption.vpcf", PATTACH_ABSORIGIN, caster)
	EmitSoundOn("Hero_Juggernaut.PreAttack", caster)
	EmitSoundOn("Hero_EarthShaker.Attack", caster)
	
	caster:StartGestureWithPlaybackRate( ACT_DOTA_VICTORY, 0.5 )
end

modifier_juggernaut_blade_dance_movement = class({})
LinkLuaModifier("modifier_juggernaut_blade_dance_movement", "heroes/hero_juggernaut/juggernaut_momentum_strike", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_juggernaut_blade_dance_movement:OnCreated()
		local parent = self:GetParent()
		self.startPos = parent:GetAbsOrigin()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance(parent, self.endPos)
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetSpecialValueFor("jump_speed") * FrameTime()
			
		
		self:StartMotionController()
	end
	
	
	function modifier_juggernaut_blade_dance_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		parent:SmoothFindClearSpace(self.endPos)
		parent:RemoveGesture( ACT_DOTA_VICTORY )
		self:StopMotionController()
	end
	
	function modifier_juggernaut_blade_dance_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local oldPos = parent:GetAbsOrigin()
			local newPos = GetGroundPosition(oldPos, parent) + self.direction * self.speed
			parent:SetAbsOrigin( newPos )
			self.distanceTraveled = self.distanceTraveled + self.speed
			ParticleManager:FireParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/dc_juggernaut_omni_slash_rope.vpcf", PATTACH_ABSORIGIN, parent, {[0] = oldPos, [2] = oldPos, [3] = newPos})
		else
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_juggernaut_blade_dance_movement:GetEffectName()
	return "particles/juggernaut_ronin_slice_buff.vpcf"
end

function modifier_juggernaut_blade_dance_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_juggernaut_blade_dance_movement:IsHidden()
	return true
end

modifier_juggernaut_momentum_strike_passive = class({})
LinkLuaModifier("modifier_juggernaut_momentum_strike_passive", "heroes/hero_juggernaut/juggernaut_momentum_strike", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_momentum_strike_passive:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_momentum_strike_passive:OnRefresh()
	self.crit_damage = self:GetSpecialValueFor("critical_bonus")
	self.crit_chance = self:GetSpecialValueFor("critical_chance")
	self.scepter_cdr = self:GetSpecialValueFor("scepter_cdr_on_hit")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_juggernaut_momentum_strike_passive:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_juggernaut_momentum_strike_passive:GetModifierCriticalDamage(params)
	local caster = self:GetCaster()
	local roll = self:RollPRNG( self.crit_chance  )
	if not caster:PassivesDisabled() and roll then
		if self:GetAbility():IsCooldownReady() then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_juggernaut_momentum_strike_momentum", {})
		else
			self:GetAbility():Refresh()
		end
		
		if caster:HasScepter() then
			for i = 0, caster:GetAbilityCount() - 1 do
				local ability = caster:GetAbilityByIndex( i )
				if ability and not ability:IsCooldownReady() then
					ability:ModifyCooldown(self.scepter_cdr)
				end
			end
		end
		
		EmitSoundOn("Hero_Juggernaut.BladeDance", caster)
		return self.crit_damage
	end
end

function modifier_juggernaut_momentum_strike_passive:IsHidden()
	return true
end

modifier_juggernaut_momentum_strike_momentum = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_juggernaut_momentum_strike_momentum", "heroes/hero_juggernaut/juggernaut_momentum_strike", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_juggernaut_momentum_strike_momentum:OnCreated()
		self.max = self:GetSpecialValueFor("maximum_charges")
		self:SetStackCount(1)
	end

	function modifier_juggernaut_momentum_strike_momentum:OnRefresh()
		self.max = self:GetSpecialValueFor("maximum_charges")
		if self:GetStackCount() < self.max then self:IncrementStackCount() end
	end
end