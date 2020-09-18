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
										if not target:TriggerSpellAbsorb(self:GetAbility()) then
											if self:GetCaster():HasScepter() then
												self:GetCaster():PerformAbilityAttack(target, true, self:GetAbility(), self.damage, nil, true)
											else
												self:GetAbility():DealDamage( self:GetCaster(), target, self.damage )
											end
											target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beast_wild_axes", {duration = self.amp})
											EmitSoundOn("Hero_Beastmaster.Wild_Axes_Damage", target)
										end
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
								local offsetVect2 = self.state * GetPerpendicularVector( self.direction ) * offset
								local calcPos = position + offsetVect
								local calcNexPos = nextPos + offsetVect2
								self:SetVelocity( CalculateDirection(calcNexPos, calcPos) * self:GetSpeed() )
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
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_beast_wild_axes_2")
	self.talent_ally = self:GetCaster():FindTalentValue("special_bonus_unique_beast_wild_axes_2")
	self:SetStackCount(1)
end

function modifier_beast_wild_axes:OnRefresh()
	self.amp = self:GetTalentSpecialValueFor("damage_amp")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_beast_wild_axes_2")
	self.talent_ally = self:GetCaster():FindTalentValue("special_bonus_unique_beast_wild_axes_2") / 100
	self:IncrementStackCount()
end

function modifier_beast_wild_axes:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_beast_wild_axes:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self.amp * self:GetStackCount()
	elseif self.talent and params.attacker:IsSameTeam( self:GetCaster() ) then
		return self.amp * self:GetStackCount() * self.talent_ally
	end
end


function modifier_beast_wild_axes:OnAttackStart(params)
	if self:GetCaster():HasModifier("modifier_cotw_hawk_spirit") 
	and params.attacker:IsSameTeam( self:GetCaster() ) 
	and params.target == self:GetParent() then
		params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_beast_wild_axes_hawk", {duration = params.attacker:GetSecondsPerAttack() + 0.1} ):SetStackCount( self.amp * self:GetStackCount() )
	end
end

function modifier_beast_wild_axes:OnTakeDamage(params)
	if self:GetCaster():HasModifier("modifier_cotw_boar_spirit")
	and params.attacker:IsSameTeam( self:GetCaster() ) 
	and params.unit == self:GetParent()
	and ( ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and not params.inflictor) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) )
	and params.attacker:GetHealth() > 0
	and not params.attacker:IsIllusion() then
		local flHeal = params.damage * ( self.amp * self:GetStackCount() / 100 )
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
		local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(lifesteal)
	end
end

modifier_beast_wild_axes_hawk = class({})
LinkLuaModifier( "modifier_beast_wild_axes_hawk", "heroes/hero_beast/beast_wild_axes.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_beast_wild_axes_hawk:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_beast_wild_axes_hawk:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end