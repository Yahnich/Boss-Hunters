beast_wild_axes = class({})

function beast_wild_axes:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local distance = CalculateDistance( caster, target )
	local direction = CalculateDirection( target, caster )
	
	local amp = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("axe_damage")
	local speed = math.max(1200, distance)
	caster:EmitSound("Hero_Beastmaster.Wild_Axes")
	local ProjectileHit = function(self, target, position)
								if not target then return end
								if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) and target:GetTeam() ~= self:GetCaster():GetTeam() then
									if not self.hitUnits[target:entindex()] then
										if self:GetCaster():HasScepter() then
											self:GetCaster():PerformAbilityAttack(target, true, self:GetAbility(), self.damage, nil, true)
										else
											self:GetAbility():DealDamage( self:GetCaster(), target, self.damage )
										end
										target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beast_wild_axes", {duration = self.amp})
										EmitSoundOn("Hero_Beastmaster.Wild_Axes_Damage", target)
										self.hitUnits[target:entindex()] = true
									end
								end
								return true
							end
	
	local ProjectileThink = function(self, target, position)
								local velocity = self:GetVelocity()
								-- 656 is just for the curve, experiment if u want
								local offset = 150 * (self.length/656) * math.sin( 2 * math.pi * self.lifetime * (656/self.length))
								self.distanceTraveled = self.distanceTraveled + speed * FrameTime()
								local position
								local nextPos
								
								if self.distanceTraveled > self.length then
									position = self.end_position + CalculateDirection( self:GetCaster():GetAbsOrigin(), self.end_position ) * (self.distanceTraveled - self.length)
									self.lifetime = self.lifetime - FrameTime()
									
									nextPos = self.end_position + CalculateDirection( self:GetCaster():GetAbsOrigin(), self.end_position ) * ( ( self.distanceTraveled + self:GetSpeed() * FrameTime() ) - self.length)
								else
									position = self.original_position + self.direction * self.distanceTraveled
									self.lifetime = self.lifetime + FrameTime()
									
									nextPos = self.original_position + self.direction * ( self.distanceTraveled + self:GetSpeed() * FrameTime() )
								end
								local offset2 = 150 * (self.length/656) * math.sin( 2 * math.pi * self.lifetime * (656/self.length))
								local offsetVect = self.state * GetPerpendicularVector( self.direction ) * offset
								local calcPos = position + offsetVect
								local calcNexPos = nextPos + offsetVect
								self:SetVelocity( CalculateDirection(calc2NexPos, calcPos) * self:GetSpeed() )
								GridNav:DestroyTreesAroundPoint( calcPos, 175, true )
								self:SetPosition( calcPos )
							end
	local position = caster:GetAbsOrigin()
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, { FX = "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",
																	  position = position,
																	  caster = self:GetCaster(),
																	  original_position = position,
																	  end_position = target,
																	  ability = self,
																	  speed = speed,
																	  radius = radius,
																	  direction = direction,
																	  velocity = -direction * speed,
																	  length = distance,
																	  distance = distance * 2,
																	  hitUnits = {},
																	  range = radius,
																	  damage = damage,
																	  lifetime = 0,
																	  distanceTraveled = 0,
																	  state = -1,
																	  amp = amp} )
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, { FX = "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",
																	  position = position,
																	  caster = self:GetCaster(),
																	  original_position = position,
																	  end_position = target,
																	  ability = self,
																	  speed = speed,
																	  radius = radius,
																	  direction = direction,
																	  velocity = -direction * speed,
																	  length = distance,
																	  distance = distance * 2,
																	  hitUnits = {},
																	  range = radius,
																	  damage = damage,
																	  lifetime = 0,
																	  distanceTraveled = 0,
																	  state = 1,
																	  amp = amp})
end

modifier_beast_wild_axes = class({})
LinkLuaModifier( "modifier_beast_wild_axes", "heroes/hero_beast/beast_wild_axes.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_beast_wild_axes:OnCreated()
	self.amp = self:GetTalentSpecialValueFor("damage_amp")
	self:SetStackCount(1)
end

function modifier_beast_wild_axes:OnRefresh()
	self.amp = self:GetTalentSpecialValueFor("damage_amp")
	self:IncrementStackCount()
end

function modifier_beast_wild_axes:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_beast_wild_axes:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self.amp * self:GetStackCount()
	end
end