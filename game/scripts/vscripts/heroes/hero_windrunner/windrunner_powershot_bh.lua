windrunner_powershot_bh = class({})

function windrunner_powershot_bh:GetIntrinsicModifierName()
	return "modifier_windrunner_powershot_bh"
end

function windrunner_powershot_bh:IsStealable()
	return true
end

function windrunner_powershot_bh:IsHiddenWhenStolen()
	return false
end

function windrunner_powershot_bh:GetCooldown( iLvl )
	if self.forceCast then
		return 0
	else
		return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_powershot_bh_1", "cdr")
	end
end

function windrunner_powershot_bh:GetCastRange( target, position )
	return self.BaseClass.GetCastRange( self, target, position ) + self:GetCaster():GetAttackRange()
end

function windrunner_powershot_bh:GetManaCost(iLvl)
	if self.forceCast then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function windrunner_powershot_bh:OnAbilityPhaseStart()
	self.forceCast = true
	return true
end

function windrunner_powershot_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end

function windrunner_powershot_bh:LaunchPowerShot(target)
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = CalculateDirection(pos, caster:GetAbsOrigin())
	
	self.forceCast = false
	self:SetCooldown()
	self:SpendMana()
	EmitSoundOn("Ability.Powershot", caster)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	local projectile = self:FireLinearProjectile("particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf", CalculateDirection( target, caster ) * self:GetTalentSpecialValueFor("arrow_speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("arrow_width"), {}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
	self.projectiles = self.projectiles or {}
	self.projectiles[projectile] = { damage= self:GetTalentSpecialValueFor("damage"), origin = caster:GetAbsOrigin() }
end

function windrunner_powershot_bh:OnProjectileHitHandle(target, position, projectile)
	if target and not target:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Ability.PowershotDamage", target)
		self:DealDamage(self:GetCaster(), target, self.projectiles[projectile].damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		local reduction = 1 - TernaryOperator( self:GetTalentSpecialValueFor("minion_reduction"), target:IsMinion(), self:GetTalentSpecialValueFor("damage_reduction") ) / 100
		self.projectiles[projectile].damage = math.floor( self.projectiles[projectile].damage * reduction )
		return self.projectiles[projectile].damage <= 0
	else
		AddFOWViewer(self:GetCaster():GetTeam(), position, self:GetTalentSpecialValueFor("vision_radius"), self:GetTalentSpecialValueFor("vision_duration"), true)
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_windrunner_powershot_bh_2") then
			local windrun = caster:FindAbilityByName("windrunner_windrun_bh")
			local duration = caster:FindTalentValue("special_bonus_unique_windrunner_powershot_bh_2", "duration") * caster:GetStatusAmplification()
			local startPos = self.projectiles[projectile].origin
			local endPos = position
			local radius = self:GetTalentSpecialValueFor("arrow_width")
			local hitPos = {}
			local talent2 = caster:HasTalent("special_bonus_unique_windrunner_windrun_bh_2")
			local duration = windrun:GetTalentSpecialValueFor("buff_duration") * caster:GetStatusAmplification()
			ParticleManager:FireParticle( "particles/units/heroes/hero_windrunner/windrunner_shinneysu_blessing.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = startPos, [1] = endPos, [2] = duration} )
			Timers:CreateTimer( function()
				local allies = caster:FindFriendlyUnitsInLine( startPos, endPos, radius )
				for _, ally in ipairs( allies ) do
					if ally:HasModifier("modifier_windrunner_windrun_bh_lesser") then
						local modifier = ally:FindModifierByName("modifier_windrunner_windrun_bh_lesser")
						modifier:SetDuration( duration, true )
					else
						ally:AddNewModifier( caster, windrun, "modifier_windrunner_windrun_bh_lesser", {duration = duration, ignoreStatusAmp = true} )
					end
				end
				duration = duration - 0.33
				if duration > 0 then
					return 0.33
				end
			end)
		end
	end
end

function windrunner_powershot_bh:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetTalentSpecialValueFor("arrow_width"), true)
end

modifier_windrunner_powershot_bh = class({})
LinkLuaModifier("modifier_windrunner_powershot_bh", "heroes/hero_windrunner/windrunner_powershot_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_windrunner_powershot_bh:IsHidden()
	return true
end

if IsServer() then
	function modifier_windrunner_powershot_bh:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_CANCELLED }
	end
	
	function modifier_windrunner_powershot_bh:OnAttackStart(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():IsCooldownReady() and (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and params.attacker:GetMana() > self:GetAbility():GetManaCost(-1) then
			EmitSoundOn("Ability.PowershotPull", params.attacker)
			self.nfx = ParticleManager:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, params.attacker)
						ParticleManager:SetParticleControlEnt(self.nfx, 0, params.attacker, PATTACH_POINT_FOLLOW, "bow_mid1", params.attacker:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(self.nfx, 1, params.attacker:GetAbsOrigin())
						ParticleManager:SetParticleControlForward(self.nfx, 1, CalculateDirection( params.target, params.attacker ) )
		end
	end
	
	
	function modifier_windrunner_powershot_bh:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():IsCooldownReady() and (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and params.attacker:GetMana() > self:GetAbility():GetManaCost(-1) then
			self:GetAbility():LaunchPowerShot(params.target)
			if self.nfx then
				StopSoundOn("Ability.PowershotPull", params.attacker)
				ParticleManager:ClearParticle( self.nfx )
				self.nfx = nil
			end
		end
	end
	
	function modifier_windrunner_powershot_bh:OnAttackCancelled(params)
		if params.attacker == self:GetParent() and self.nfx then
			StopSoundOn("Ability.PowershotPull", params.attacker)
			ParticleManager:ClearParticle( self.nfx )
			self.nfx = nil
			self:GetAbility().forceCast = false
		end
	end
end