juggernaut_ronins_wind = class({})

function juggernaut_ronins_wind:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster.AttemptDecrementMomentum and caster:AttemptDecrementMomentum(1) then
		self:Refresh()
	end
	
	caster:AddNewModifier( caster, self, "modifier_juggernaut_ronins_wind_movement", {duration = CalculateDistance(caster, self:GetCursorPosition()) / self:GetTalentSpecialValueFor("speed")} )
	ParticleManager:FireParticle("particles/frostivus_herofx/juggernaut_omnislash_ascension.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption.vpcf", PATTACH_ABSORIGIN, caster)
	EmitSoundOn("Hero_Juggernaut.PreAttack", caster)
	EmitSoundOn("Hero_EarthShaker.Attack", caster)
	if caster:HasTalent("special_bonus_unique_juggernaut_ronins_wind_2") then
		ParticleManager:FireParticle("particles/units/heroes/hero_treant/treant_leech_seed_heal_puffs.vpcf", PATTACH_POINT_FOLLOW, caster)
		caster:HealEvent( caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_juggernaut_ronins_wind_2") / 100, self, caster )
	end
	caster:StartGestureWithPlaybackRate( ACT_DOTA_VICTORY, 8 )
end


modifier_juggernaut_ronins_wind_movement = class({})
LinkLuaModifier("modifier_juggernaut_ronins_wind_movement", "heroes/hero_juggernaut/juggernaut_ronins_wind", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_juggernaut_ronins_wind_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance(parent, self.endPos)
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()
		self:StartMotionController()
	end
	
	
	function modifier_juggernaut_ronins_wind_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		parent:SmoothFindClearSpace(self.endPos)
		parent:RemoveGesture( ACT_DOTA_VICTORY )
		self:StopMotionController()
	end
	
	function modifier_juggernaut_ronins_wind_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local oldPos = parent:GetAbsOrigin()
			local newPos = GetGroundPosition(oldPos, parent) + self.direction * self.speed
			parent:SetAbsOrigin( newPos )
			if parent:HasTalent("special_bonus_unique_juggernaut_ronins_wind_1") then
				if not self.targetsHit then self.targetsHit = {} end
				for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( newPos, parent:GetAttackRange() ) ) do
					if not self.targetsHit[enemy:entindex()] then
						self.targetsHit[enemy:entindex()] = true
						ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN , enemy)
						if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then parent:PerformGenericAttack(enemy, true) end
					end
				end
			end
			ParticleManager:FireParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/dc_juggernaut_omni_slash_rope.vpcf", PATTACH_ABSORIGIN, parent, {[0] = oldPos, [2] = oldPos, [3] = newPos})
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_juggernaut_ronins_wind_movement:GetEffectName()
	return "particles/juggernaut_ronin_slice_buff.vpcf"
end

function modifier_juggernaut_ronins_wind_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_juggernaut_ronins_wind_movement:IsHidden()
	return true
end