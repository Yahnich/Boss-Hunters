visage_soul = class({})
LinkLuaModifier( "modifier_visage_soul_handle", "heroes/hero_visage/visage_soul.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_visage_soul_stacks", "heroes/hero_visage/visage_soul.lua" ,LUA_MODIFIER_MOTION_NONE )

function visage_soul:IsStealable()
    return true
end

function visage_soul:IsHiddenWhenStolen()
    return false
end

function visage_soul:GetIntrinsicModifierName()
    return "modifier_visage_soul_handle"
end

function visage_soul:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Visage.SoulAssumption.Cast", caster)

	self:ReleaseSouls(target)

	if caster:HasTalent("special_bonus_unique_visage_soul_1") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				self:ReleaseSouls(enemy)
				break
			end
		end
	end

	caster:RemoveModifierByName("modifier_visage_soul_stacks")
end

function visage_soul:ReleaseSouls(hTarget)
	local caster = self:GetCaster()

	local speed = 1000

	self.currentStacks = 0

	if caster:HasModifier("modifier_visage_soul_stacks") then
		self.currentStacks = caster:FindModifierByName("modifier_visage_soul_stacks"):GetStackCount()
		if self.currentStacks < 6 then
			self:FireTrackingProjectile("particles/units/heroes/hero_visage/visage_soul_assumption_bolt" .. self.currentStacks .. ".vpcf", hTarget, speed , {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
		else
			self:FireTrackingProjectile("particles/units/heroes/hero_visage/visage_soul_assumption_bolt6.vpcf", hTarget, speed , {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
		end
	else
		self:FireTrackingProjectile("particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf", hTarget, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
	end
end

function visage_soul:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	local baseDamage = self:GetTalentSpecialValueFor("base_damage")
	local stackDamage = self:GetTalentSpecialValueFor("charge_damage") * self.currentStacks

	local totalDamage = baseDamage + stackDamage

	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then

		EmitSoundOn("Hero_Visage.SoulAssumption.Target", hTarget)

		if caster:HasTalent("special_bonus_unique_visage_soul_2") and self:RollPRNG(caster:FindTalentValue("special_bonus_unique_visage_soul_1")) then
			self:IncrementStacks()
		end

		self:DealDamage(caster, hTarget, totalDamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

function visage_soul:IncrementStacks()
	local caster = self:GetCaster()

	local maxStacks = self:GetTalentSpecialValueFor("stack_limit")
	
	if caster:HasModifier("modifier_visage_soul_stacks") then
		if caster:FindModifierByName("modifier_visage_soul_stacks"):GetStackCount() < maxStacks then
			caster:AddNewModifier(caster, self, "modifier_visage_soul_stacks", {}):IncrementStackCount()
		end
	else
		caster:AddNewModifier(caster, self, "modifier_visage_soul_stacks", {}):IncrementStackCount()
	end
end

modifier_visage_soul_handle = class({})
function modifier_visage_soul_handle:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		self.health_check = self:GetTalentSpecialValueFor("health_check")/100

		self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_soul_counter.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleAlwaysSimulate(self.nfx)
					ParticleManager:SetParticleControlEnt(self.nfx, 0, caster, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.nfx, 1, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 2, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))
		self:AttachEffect(self.nfx)

		self:StartIntervalThink(0.1)			
	end
end

function modifier_visage_soul_handle:OnRefresh(table)
	if IsServer() then
		self.health_check = self:GetTalentSpecialValueFor("health_check")/100
	end
end

function modifier_visage_soul_handle:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		self.health_check = self:GetTalentSpecialValueFor("health_check")/100

		local modifier = caster:FindModifierByName("modifier_visage_soul_stacks")
		if modifier then
			if modifier:GetStackCount() >= 0 then
				ParticleManager:SetParticleControl(self.nfx, 1, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 2, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
				ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

				if modifier:GetStackCount() >= 1 then
					ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
					ParticleManager:SetParticleControl(self.nfx, 2, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
					ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

					if modifier:GetStackCount() >= 2 then
						ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
						ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
						ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
						ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
						ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
						ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
						ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
						ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
						ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

						if modifier:GetStackCount() >= 3 then
							ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
							ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
							ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
							ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
							ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
							ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
							ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
							ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
							ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

							if modifier:GetStackCount() >= 4 then
								ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
								ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
								ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
								ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
								ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
								ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
								ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
								ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
								ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

								if modifier:GetStackCount() >= 5 then
									ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
									ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
									ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
									ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
									ParticleManager:SetParticleControl(self.nfx, 5, Vector(1,0,0))
									ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
									ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
									ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
									ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

									if modifier:GetStackCount() >= 6 then
										ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
										ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
										ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
										ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
										ParticleManager:SetParticleControl(self.nfx, 5, Vector(1,0,0))
										ParticleManager:SetParticleControl(self.nfx, 6, Vector(1,0,0))
										ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
										ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
										ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

										if modifier:GetStackCount() >= 7 then
											ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 5, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 6, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 7, Vector(1,0,0))
											ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
											ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

											if modifier:GetStackCount() >= 8 then
												ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 5, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 6, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 7, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 8, Vector(1,0,0))
												ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))

												if modifier:GetStackCount() >= 9 then
													ParticleManager:SetParticleControl(self.nfx, 1, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 2, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 3, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 4, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 5, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 6, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 7, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 8, Vector(1,0,0))
													ParticleManager:SetParticleControl(self.nfx, 9, Vector(1,0,0))

												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		else
			ParticleManager:SetParticleControl(self.nfx, 1, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 2, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 3, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 4, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 5, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 6, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 7, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 8, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.nfx, 9, Vector(0,0,0))
		end
	end
end

function modifier_visage_soul_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_visage_soul_handle:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit
		
		if unit:GetTeam() == caster:GetTeam() then
			if unit.damage then
				unit.damage = unit.damage + params.damage
			else
				unit.damage = params.damage
			end

			local health = unit:GetMaxHealth() * self.health_check
			if unit.damage >= health then
				unit.damage = 0
				self:GetAbility():IncrementStacks()
			end
		end
	end
end

function modifier_visage_soul_handle:IsHidden()
	return true
end

modifier_visage_soul_stacks = class({})