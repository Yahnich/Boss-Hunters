void_spirit_dissimilate_bh = class({})

function void_spirit_dissimilate_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin()
	self.portals = {}
	self:CreatePortal( position, true )
	local portals = self:GetTalentSpecialValueFor("portals_per_ring")
	local angle = self:GetTalentSpecialValueFor("angle_per_ring_portal")
	local distance = self:GetTalentSpecialValueFor("first_ring_distance_offset")
	local direction = Vector( 1, 0, 0 )
	for i = 1, portals do
		direction = RotateVector2D( direction, ToRadians( angle ) )
		local newPos = position + direction * distance
		self:CreatePortal( newPos, false )
	end
	caster:Stop()
	caster:Interrupt()
	caster:Hold()
	caster:AddNewModifier( caster, self, "modifier_void_spirit_dissimilate_oow", {duration = self:GetTalentSpecialValueFor("phase_duration")})
	EmitSoundOn( "Hero_VoidSpirit.Dissimilate.Cast", caster )
end

function void_spirit_dissimilate_bh:CreatePortal( position, active )
	local caster = self:GetCaster()
	local radius = self:GetTalentSpecialValueFor("damage_radius")
	local duration = self:GetTalentSpecialValueFor("phase_duration")
	local damage = self:GetTalentSpecialValueFor("damage")
	local fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( fx, 0, position )
	ParticleManager:SetParticleControl( fx, 1, Vector( radius, 0, 0 ) )
	ParticleManager:SetParticleControl( fx, 2, Vector( (active and 1) or 0, 0, 0 ) )
	Timers:CreateTimer( duration, function()
		if self.portals[fx].active then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
				damageDealt = damage
				if caster:HasTalent("special_bonus_unique_void_spirit_dissimilate_2") and enemy:IsMinion() then
					damageDealt = damageDealt * caster:FindTalentValue("special_bonus_unique_void_spirit_dissimilate_2")
				end
				if caster:HasTalent("special_bonus_unique_void_spirit_dissimilate_1") then
					enemy:AddNewModifier( caster, self, "modifier_void_spirit_dissimilate_talent", {duration = caster:FindTalentValue("special_bonus_unique_void_spirit_dissimilate_1", "duration")} )
				end
				self:DealDamage( caster, enemy, damageDealt )
			end
			ParticleManager:FireParticle( "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf", PATTACH_CUSTOMORIGIN, caster, {[0] = position, [1] = Vector( radius, 1, 1 ) } )
			ParticleManager:FireParticle( "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_exit.vpcf", PATTACH_POINT_FOLLOW, caster )
			FindClearSpaceForUnit( caster, position, true)
			EmitSoundOn( "Hero_VoidSpirit.Dissimilate.TeleportIn", caster )
			
		end
		ParticleManager:ClearParticle( fx )
	end)
	self.portals[fx] = {position = position, active = active}
end

modifier_void_spirit_dissimilate_talent = class({})
LinkLuaModifier( "modifier_void_spirit_dissimilate_talent", "heroes/hero_void_spirit/void_spirit_dissimilate_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_void_spirit_dissimilate_talent:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_dissimilate_1")
end

function modifier_void_spirit_dissimilate_talent:OnRefresh()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_dissimilate_1")
end

function modifier_void_spirit_dissimilate_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_void_spirit_dissimilate_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_void_spirit_dissimilate_talent:GetStatusEffectName()
	return "particles/status_fx/status_effect_void_spirit_aether_remnant.vpcf"
end

function modifier_void_spirit_dissimilate_talent:StatusEffectPriority()
	return 10
end

modifier_void_spirit_dissimilate_oow = class({})
LinkLuaModifier( "modifier_void_spirit_dissimilate_oow", "heroes/hero_void_spirit/void_spirit_dissimilate_bh", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_void_spirit_dissimilate_oow:OnCreated()
		self:GetCaster():AddNoDraw()
	end

	function modifier_void_spirit_dissimilate_oow:OnDestroy()
		self:GetCaster():RemoveNoDraw()
	end
end

function modifier_void_spirit_dissimilate_oow:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end

function modifier_void_spirit_dissimilate_oow:OnOrder( params )
	if params.unit == self:GetParent() then
		if params.order_type == 1 and params.new_pos ~= Vector(0, 0, 0) then
			local ability = self:GetAbility()
			local portals = ability.portals
			local nearestPortal
			local nearestDistance = 99999
			for fx, portalData in pairs( portals ) do
				ParticleManager:SetParticleControl( fx, 2, Vector( (active and 1) or 0, 0, 0 ) )
				portalData.active = false
				if CalculateDistance( portalData.position, params.new_pos ) < nearestDistance then
					nearestPortal = fx
					nearestDistance = CalculateDistance( portalData.position, params.new_pos )
				end
			end
			portals[nearestPortal].active = true
			ParticleManager:SetParticleControl( nearestPortal, 2, Vector( 1, 0, 0 ) )
		end
	end
end

function modifier_void_spirit_dissimilate_oow:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
			}
end

function modifier_void_spirit_dissimilate_oow:IsHidden()
	return true
end