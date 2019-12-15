earthshaker_crater_impact = class({})

function earthshaker_crater_impact:IsStealable()
	return true
end

function earthshaker_crater_impact:IsHiddenWhenStolen()
	return false
end

function earthshaker_crater_impact:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("jump_distance")
end

function earthshaker_crater_impact:OnSpellStart()
	local caster = self:GetCaster()
	local duration =  self:GetTalentSpecialValueFor("jump_duration") + 0.01
	caster:AddNewModifier(caster, self, "modifier_earthshaker_crater_impact_movement", {duration = duration})
	if caster:HasTalent("special_bonus_unique_earthshaker_crater_impact_2") then
		caster:AddNewModifier(caster, self, "modifier_earthshaker_crater_impact_talent", {duration = duration + caster:FindTalentValue("special_bonus_unique_earthshaker_crater_impact_2", "duration")})
	end
end

function earthshaker_crater_impact:CreateQuake(position, radius, damage)
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Leshrac.Split_Earth", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_crater_impact.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, radius, radius)})
	
	local talent2 = caster:HasTalent("special_bonus_unique_earthshaker_crater_impact_2")
	local stunDuration = self:GetTalentSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, enemy, damage)
			self:Stun(enemy, stunDuration, false)
			if talent2 then
				enemy:Taunt(self, caster, caster:FindTalentValue("special_bonus_unique_earthshaker_crater_impact_2", "duration") )
			end
		end
	end
end

modifier_earthshaker_crater_impact_movement = class({})
LinkLuaModifier("modifier_earthshaker_crater_impact_movement", "heroes/hero_earthshaker/earthshaker_crater_impact", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_earthshaker_crater_impact_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetTalentSpecialValueFor("jump_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 650
		self:StartMotionController()
	end
	
	
	function modifier_earthshaker_crater_impact_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local damage = self:GetTalentSpecialValueFor("damage")
		local radius = self:GetTalentSpecialValueFor("radius")
		ability:CreateQuake(parentPos, radius, damage)
		if parent:HasTalent("special_bonus_unique_earthshaker_crater_impact_1") then
			local delay = parent:FindTalentValue("special_bonus_unique_earthshaker_crater_impact_1", "duration")
			local multiplier = parent:FindTalentValue("special_bonus_unique_earthshaker_crater_impact_1")
			local radMult = parent:FindTalentValue("special_bonus_unique_earthshaker_crater_impact_1", "radius")
			Timers:CreateTimer( delay, function() ability:CreateQuake(parentPos, radius * radMult, damage * multiplier) end)
		end
		self:StopMotionController()
	end
	
	function modifier_earthshaker_crater_impact_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_earthshaker_crater_impact_movement:GetEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_crater_impact_blur.vpcf"
end

function modifier_earthshaker_crater_impact_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_earthshaker_crater_impact_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_earthshaker_crater_impact_movement:GetModifierIncomingDamage_Percentage()
	return self:GetTalentSpecialValueFor("reduction")
end

function modifier_earthshaker_crater_impact_movement:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_2
end

modifier_earthshaker_crater_impact_talent = class({})
LinkLuaModifier("modifier_earthshaker_crater_impact_talent", "heroes/hero_earthshaker/earthshaker_crater_impact", LUA_MODIFIER_MOTION_NONE)

function modifier_earthshaker_crater_impact_talent:OnCreated()
	self.armor = self:GetParent():GetPhysicalArmorValue(false) * self:GetParent():FindTalentValue("special_bonus_unique_earthshaker_crater_impact_2")
end

function modifier_earthshaker_crater_impact_talent:OnRefresh()
	self.armor = 0
	self.armor = self:GetParent():GetPhysicalArmorValue(false) * self:GetParent():FindTalentValue("special_bonus_unique_earthshaker_crater_impact_2")
end

function modifier_earthshaker_crater_impact_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_earthshaker_crater_impact_talent:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_earthshaker_crater_impact_talent:GetEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_crater_impact_armor.vpcf"
end

function modifier_earthshaker_crater_impact_talent:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_vr_desat_stone.vpcf"
end

function modifier_earthshaker_crater_impact_talent:StatusEffectPriority()
	return 5
end