boss_wolves_leap = class({})

function boss_wolves_leap:OnAbilityPhaseStart()
	local casterPos = self:GetCaster():GetAbsOrigin()
	local target = self:GetCursorPosition()
	local direction = CalculateDirection(target, casterPos)
	local distance = math.min( CalculateDistance( target, casterPos ), self:GetSpecialValueFor("distance") )
	ParticleManager:FireLinearWarningParticle( casterPos, casterPos + direction * distance, self:GetCaster():GetHullRadius() )
	return true
end

function boss_wolves_leap:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_wolves_leap", {})
end

modifier_boss_wolves_leap = class({})
LinkLuaModifier("modifier_boss_wolves_leap", "bosses/boss_wolves/boss_wolves_leap", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_wolves_leap:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = math.min( CalculateDistance( self.endPos, parent ), self:GetSpecialValueFor("distance") )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetSpecialValueFor("speed") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = self:GetSpecialValueFor("max_height")
		self:StartMotionController()
	end
	
	function modifier_boss_wolves_leap:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled <= self.distance and not parent:IsStunned() and not parent:IsRooted() then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			local newPos = GetGroundPosition(self.endPos, parent)
			parent:SetAbsOrigin( newPos )
			
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
	end
end