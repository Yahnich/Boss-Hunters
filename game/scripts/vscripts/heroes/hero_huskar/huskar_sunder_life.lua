huskar_sunder_life = class({})

function huskar_sunder_life:IsStealable()
	return true
end

function huskar_sunder_life:IsHiddenWhenStolen()
	return false
end

function huskar_sunder_life:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_huskar_sunder_life_2")
end

function huskar_sunder_life:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local distance = CalculateDistance(targetPos, caster)
	local duration = distance / self:GetTalentSpecialValueFor("charge_speed")
	caster:AddNewModifier(caster, self, "modifier_huskar_sunder_life_movement", {duration = duration})
	EmitSoundOn("Hero_Huskar.Life_Break", caster)
end

function huskar_sunder_life:SunderLife(position)
	local caster = self:GetCaster()
	local damagePct = TernaryOperator(self:GetTalentSpecialValueFor("health_damage_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("health_cost_percent")) / 100
	local damage = caster:GetHealth() * damagePct
	self:DealDamage( caster, caster, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL})
	if caster:HasTalent("special_bonus_unique_huskar_sunder_life_1") then
		caster:AddNewModifier( caster, self, "modifier_huskar_sunder_life_talent", {duration = caster:FindTalentValue("special_bonus_unique_huskar_sunder_life_1", "duration")} )
	end
	local enemies = caster:FindEnemyUnitsInRadius(position, self:GetTalentSpecialValueFor("damage_radius"))
	for _, enemy in ipairs( enemies ) do
		local eDamage = enemy:GetHealth() * damagePct
		self:DealDamage( caster, enemy, eDamage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		enemy:AddNewModifier(caster, self, "modifier_huskar_sunder_life_debuff", {duration = self:GetTalentSpecialValueFor("slow_duration")})
	end
end

modifier_huskar_sunder_life_talent = class({})
LinkLuaModifier("modifier_huskar_sunder_life_talent", "heroes/hero_huskar/huskar_sunder_life", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_sunder_life_talent:IsHidden()
	return true
end

modifier_huskar_sunder_life_movement = class({})
LinkLuaModifier("modifier_huskar_sunder_life_movement", "heroes/hero_huskar/huskar_sunder_life", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_huskar_sunder_life_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetTalentSpecialValueFor("charge_speed") * FrameTime()
		self:StartMotionController()
	end
	
	
	function modifier_huskar_sunder_life_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		ability:SunderLife(parentPos)
		self:StopMotionController()
	end
	
	function modifier_huskar_sunder_life_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() then
			local newPos = GetGroundPosition(parent:GetAbsOrigin() + self.direction * self.speed, parent) 
			parent:SetAbsOrigin( newPos )
			if self.distanceTraveled < self.distance then
				self.distanceTraveled = self.distanceTraveled + self.speed
			else
				self:Destroy()
				return nil
			end       
		end
	end
end

function modifier_huskar_sunder_life_movement:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_life_break.vpcf"
end

function modifier_huskar_sunder_life_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_huskar_sunder_life_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_huskar_sunder_life_movement:GetOverrideAnimation()
	return ACT_DOTA_CAST_LIFE_BREAK_START
end

modifier_huskar_sunder_life_debuff = class({})
LinkLuaModifier("modifier_huskar_sunder_life_debuff", "heroes/hero_huskar/huskar_sunder_life", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_sunder_life_debuff:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("movespeed")
end

function modifier_huskar_sunder_life_debuff:OnRefresh()
	self.slow = self:GetTalentSpecialValueFor("movespeed")
end

function modifier_huskar_sunder_life_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_huskar_sunder_life_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_huskar_sunder_life_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_huskar_lifebreak.vpcf"
end

function modifier_huskar_sunder_life_debuff:StatusEffectPriority()
	return 3
end