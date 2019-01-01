beast_wild_axes = class({})

function beast_wild_axes:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local distance = CalculateDistance( caster, target )
	local direction = CalculateDirection( caster, target )
	
	caster:EmitSoundOn("Hero_Beastmaster.Wild_Axes")
	local ProjectileHit = 	function(self, target, position)
								if not target then return end
								if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) and target:GetTeam() ~= self:GetCaster():GetTeam() then
									if not self.hitUnits[target:entindex()] then
										self:GetAbility():DealDamage( self:GetCaster(), target, self.damage )
										target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beast_wild_axes", {duration = self.amp})
										EmitSoundOn("Hero_Beastmaster.Wild_Axes_Damage", target)
										self.hitUnits[target:entindex()] = true
									end
								end
								return true
							end
	
	local ProjectileThink = function(self, target, position)
								local position = self:GetPosition()
								local velocity = self:GetVelocity()
								
								local offset = 128 * ( 0.5 * self.lifetime )
								
								self.distanceTraveled = self.distanceTraveled + speed * FrameTime()
								local position = original_position + direction * self.distanceTraveled
								if self.distanceTraveled > self.distance then
									position = end_position - direction * (self.distanceTraveled - self.distance)
								end
								local offsetVect = self.state * GetPerpendicularVector( position:Normalized() ) * offset
								self:SetPosition( position + offsetVect )
								
								-- if velocity.z > 0 then velocity.z = 0 end
								-- local angularVel = ( self.speed / self.range )
								-- direction = CalculateDirection( position, self:GetCaster() )
								-- if self.aliveTime >= self.duration / 2 then
									-- self.range = self.range - self.radialSpeed * FrameTime()
									-- direction = -direction
								-- else
									-- self.range = self.range + self.radialSpeed * FrameTime()
								-- end
								-- self.angle = self.angle + angularVel
								-- local newPosition = caster:GetAbsOrigin() + RotateVector2D(self:GetVelocity(), ToRadians( self.angle ) ) * self.range
								-- self:SetPosition( newPosition + Vector(0,0,128) )
							end
	local position = caster:GetAbsOrigin() - vDir * radius + Vector(0,0,256)
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, { FX = "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",
																	  position = position,
																	  caster = self:GetCaster(),
																	  original_position = position,
																	  end_position = target,
																	  ability = self,
																	  speed = speed,
																	  radius = radius,
																	  direction = direction,
																	  velocity = -vDir * speed,
																	  distance = distance,
																	  hitUnits = {},
																	  range = radius,
																	  damage = damage,
																	  self.lifetime = 0,
																	  self.distanceTraveled = 0,
																	  self.state = -1
																	  amp = amp})
end

modifier_beast_wild_axes = class({})
LinkLuaModifier( "modifier_beast_wild_axes", "heroes/hero_beast/beast_wild_axes.lua" ,LUA_MODIFIER_MOTION_NONE )