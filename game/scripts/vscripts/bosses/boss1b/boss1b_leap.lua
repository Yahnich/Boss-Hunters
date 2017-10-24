boss1b_leap = class({})

function boss1b_leap:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("leap_radius"))
	return true
end

function boss1b_leap:OnSpellStart()
	local caster = self:GetCaster()
	local endPos = self:GetCursorPosition()
	-- run around like an idiot
	caster:Interrupt()
	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = endPos, 
	})
	caster:AddNewModifier( caster, self, "modifier_boss1b_leap_attack_thinker", {duration = CalculateDistance(caster, endPos)/self:GetSpecialValueFor("leap_speed")})
end


modifier_boss1b_leap_attack_thinker = class({})
LinkLuaModifier("modifier_boss1b_leap_attack_thinker", "bosses/boss1b/boss1b_leap.lua", 0)

function modifier_boss1b_leap_attack_thinker:OnCreated()
	self.distance = 0
	self.horSpeed = self:GetSpecialValueFor("leap_speed") * FrameTime()
	self.verSpeed = self:GetSpecialValueFor("leap_height") / (self:GetDuration() / 2) * FrameTime()
	self.verAcc = - (self.verSpeed / (self:GetDuration() / 2))  * FrameTime()
	if IsServer() then 
		self.direction = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent())
		self:GetParent():Interrupt()
		self:GetParent():Hold()
		self:StartMotionController()
	end
end

function modifier_boss1b_leap_attack_thinker:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("leap_radius"))) do
			self:GetAbility():DealDamage(enemy, self:GetParent(), self:GetSpecialValueFor("leap_damage"))
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss1b_leap_slow", {duration = self:GetSpecialValueFor("slow_duration")})
			self:StopMotionController()
		end
		
	end
end

function modifier_boss1b_leap_attack_thinker:DoControlledMotion()
	if self:GetParent():IsNull() then return end
	local parent = self:GetParent()
	if parent:IsAlive() then
		parent:SetAbsOrigin( (self.prevLoc or parent:GetAbsOrigin()) + self.direction * self.horSpeed * Vector(1,1,0) )
		parent:SetAbsOrigin( parent:GetAbsOrigin() + Vector(0,0,self.verSpeed) )
		
		self.prevLoc = parent:GetAbsOrigin()
		self.verSpeed = self.verSpeed + self.verAcc
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:Destroy()
		return nil
	end       
	
end

function modifier_boss1b_leap_attack_thinker:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_boss1b_leap_attack_thinker:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

modifier_boss1b_leap_slow = class({})
LinkLuaModifier("modifier_boss1b_leap_slow", "bosses/boss1b/boss1b_leap.lua", 0)


function modifier_boss1b_leap_slow:OnCreated()
	self.ms = self:GetSpecialValueFor("leap_slow")
end

function modifier_boss1b_leap_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss1b_leap_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss1b_leap_slow:GetEffectName()
	return "particles/items3_fx/silver_edge_slow.vpcf"
end