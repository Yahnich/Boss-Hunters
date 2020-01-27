troll_warlord_whirling_axes = class({})

function troll_warlord_whirling_axes:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("whirl_duration")
	self:SummonWhirlingAxe( duration, caster:GetForwardVector() )
	self:SummonWhirlingAxe( duration, -caster:GetForwardVector() )
	caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Melee")
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
end

function troll_warlord_whirling_axes:SummonWhirlingAxe( duration, direction )
	local caster = self:GetCaster()
	local vDir = direction or caster:GetForwardVector()
	
	local radius = self:GetTalentSpecialValueFor("hit_radius")
	local speed = self:GetTalentSpecialValueFor("axe_movement_speed") 
	local maxRange = self:GetTalentSpecialValueFor("max_range")
	local damage = self:GetTalentSpecialValueFor("damage")
	local blind = self:GetTalentSpecialValueFor("blind_duration")
	
	local ProjectileHit = 	function(self, target, position)
								if not target then return end
								if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) and target:GetTeam() ~= self:GetCaster():GetTeam() then
									if not self.hitUnits[target:entindex()] then
										if not target:TriggerSpellAbsorb( self:GetAbility() ) then
											self:GetAbility():DealDamage( self:GetCaster(), target, self.damage )
											target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_troll_warlord_whirling_axes", {duration = self.blind})
											EmitSoundOn("Hero_TrollWarlord.WhirlingAxes.Target", target)
										end
										self.hitUnits[target:entindex()] = true
									end
								end
								return true
							end
	
	local ProjectileThink = function(self, target, position)
								local position = self:GetPosition()
								local velocity = self:GetVelocity()
								if velocity.z > 0 then velocity.z = 0 end
								local angularVel = ( self.speed / self.range )
								direction = CalculateDirection( position, self:GetCaster() )
								if self.aliveTime >= self.duration / 2 then
									self.range = self.range - self.radialSpeed * FrameTime()
									direction = -direction
								else
									self.range = self.range + self.radialSpeed * FrameTime()
								end
								self.angle = self.angle + angularVel
								local newPosition = caster:GetAbsOrigin() + RotateVector2D(self:GetVelocity(), ToRadians( self.angle ) ) * self.range
								self:SetPosition( newPosition + Vector(0,0,128) )
							end
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, { FX = "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf",
																	  position = caster:GetAbsOrigin() - vDir * radius + Vector(0,0,256),
																	  caster = self:GetCaster(),
																	  ability = self,
																	  speed = speed,
																	  radius = radius,
																	  velocity = -vDir * speed,
																	  duration = duration,
																	  hitUnits = {},
																	  range = radius,
																	  radialSpeed = ((maxRange - radius)/2) / duration,
																	  angle = 0,
																	  damage = damage,
																	  blind = blind})
end

modifier_troll_warlord_whirling_axes = class({})
LinkLuaModifier("modifier_troll_warlord_whirling_axes", "heroes/hero_troll_warlord/troll_warlord_whirling_axes", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_whirling_axes:OnCreated()
	self.blind = self:GetTalentSpecialValueFor("blind_pct")
end

function modifier_troll_warlord_whirling_axes:OnRefresh()
	self.blind = self:GetTalentSpecialValueFor("blind_pct")
end

function modifier_troll_warlord_whirling_axes:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_troll_warlord_whirling_axes:GetModifierMiss_Percentage()
	return self.blind
end