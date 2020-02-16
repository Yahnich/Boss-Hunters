grimstroke_stroke = class({})
LinkLuaModifier("modifier_grimstroke_stroke_slow", "heroes/hero_grimstroke/grimstroke_stroke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_stroke_spot", "heroes/hero_grimstroke/grimstroke_stroke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_stroke_spot_damage", "heroes/hero_grimstroke/grimstroke_stroke", LUA_MODIFIER_MOTION_NONE)

function grimstroke_stroke:IsStealable()
    return true
end

function grimstroke_stroke:IsHiddenWhenStolen()
    return false
end

function grimstroke_stroke:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Grimstroke.DarkArtistry.PreCastPoint", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2", [1]="attach_attack2"})

    return true
end

function grimstroke_stroke:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Grimstroke.DarkArtistry.Cast", caster)
	EmitSoundOn("Hero_Grimstroke.DarkArtistry.Cast.Layer", caster)
	EmitSoundOn("Hero_Grimstroke.DarkArtistry.Projectile", caster)

	self:LaunchBlood()
end

function grimstroke_stroke:LaunchBlood()
	local caster = self:GetCaster()
	local endPos = self:GetCursorPosition()

	local startPos = caster:GetAbsOrigin() - caster:GetRightVector() * 120

	local distance = self:GetTrueCastRange()
	local direction = CalculateDirection(endPos, startPos)

	local speed = 2400

	local velocity = direction * speed

	local startWidth = 120
	local endRadius = 160

	local visionDuration = 2

	local slow_duration = self:GetSpecialValueFor("slow_duration")

	local baseDamage = self:GetSpecialValueFor("damage")
	local damageGain = self:GetSpecialValueFor("bonus_damage_per_target")

	local duration = distance/speed

	local bTalent = false

	local talentDuration = 5
	local talentHeal = caster:GetMaxHealth() * 1/100

	if caster:HasTalent("special_bonus_unique_grimstroke_stroke_1") then
		bTalent = true
	end

	--Purely cosmetic only-------
	self:FireLinearProjectile("particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_proj.vpcf", direction*speed, distance, startWidth, {origin = startPos, width_end = endRadius}, false, true, 160)	
	--self:FireLinearProjectile("particles/econ/items/spectre/spectre_transversant_soul/spectre_ti7_crimson_spectral_dagger.vpcf", direction*speed, distance, startWidth, {origin = startPos, width_end = endRadius}, false, true, 160)	
	-----------------------------

	--Projectile Data------------
	--OnHit data-----------------
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.hitUnits = self.hitUnits or {}
		if not self.hitUnits[target:entindex()] then
			if target:TriggerSpellAbsorb(self) then return false end

			EmitSoundOn("Hero_Grimstroke.DarkArtistry.Damage", caster)
		
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_dmg.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), 160, self.vision_duration, true)

			target:AddNewModifier(caster, ability, "modifier_grimstroke_stroke_slow", {Duration = self.modDur})

			--Talent 2
			if caster:HasTalent("special_bonus_unique_grimstroke_stroke_2") then
				local abilityBlood = caster:FindAbilityByName("grimstroke_blood")
				abilityBlood:CreateInkSpot( target:GetAbsOrigin(), target:IsMinion() )
			end

			ability:DealDamage(caster, target, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

			self.damage = self.damage + self.damage_gain
			self.hitUnits[target:entindex()] = true
		end

		return true
	end
	
	--OnThink data--------------
	local ProjectileThink = function(self)
		local caster = self:GetCaster()
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		if velocity.z > 0 then velocity.z = 0 end

		self.previousPoint = self.previousPoint or position
		self.tempRadius = self.tempRadius or self.radius

		local totalDistance = self.distance

		self:SetPosition( position + (velocity*FrameTime()) )

		if CalculateDistance(self.previousPoint, position) >= self.tempRadius * 2 then
			AddFOWViewer(caster:GetTeam(), position, self.tempRadius, self.vision_duration, true)

			--Talent 1-----
			if self.talent then
				self:GetAbility().lastDamageDealt = self.damage
				CreateModifierThinker(caster, self:GetAbility(), "modifier_grimstroke_stroke_spot", {Duration = self.talent_duration, Radius = self.tempRadius, damage = self.damage}, position, caster:GetTeamNumber(), false)
			end

			self.previousPoint = position
		end

		--Scale the radius-----
		--Change the radius relative to the current position
		local radiusStep = (self.end_radius - self.radius) / (totalDistance / velocity:Length()) * FrameTime()
		self.tempRadius = self.tempRadius + radiusStep
		self:SetRadius(self.tempRadius)
	end

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  	
		FX = "",
		position = startPos,
		caster = caster,
		ability = self,
		speed = speed,
		radius = startWidth,
		end_radius = endRadius,
		velocity = velocity,
		distance = distance,
		damage = baseDamage,
		damage_gain = damageGain,
		vision_duration = visionDuration,
		modDur = slow_duration,
		duration = duration,
		talent = bTalent,
		talent_duration = talentDuration,
		talent_heal = talentHeal
	})
end

modifier_grimstroke_stroke_slow = class({})
function modifier_grimstroke_stroke_slow:OnCreated(table)
	self.ms_slow = self:GetSpecialValueFor("movement_slow_pct")
end

function modifier_grimstroke_stroke_slow:OnRefresh(table)
	self.ms_slow = self:GetSpecialValueFor("movement_slow_pct")
end

function modifier_grimstroke_stroke_slow:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_grimstroke_stroke_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow 
end

function modifier_grimstroke_stroke_slow:IsDebuff()
	return true
end

function modifier_grimstroke_stroke_slow:IsPurgable()
	return true
end

modifier_grimstroke_stroke_spot = class({})
function modifier_grimstroke_stroke_spot:OnCreated(table)
    if IsServer() then
    	local parent = self:GetParent()
    	local caster = self:GetCaster()
    	local point = parent:GetAbsOrigin()
    	self.point = parent:GetAbsOrigin()
    	self.radius = table.Radius
    	
    	--Debug stuff--
    	--print(radius)

    	AddFOWViewer(parent:GetTeam(), point, self.radius, self:GetDuration(), true)

    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_blood_stroke.vpcf", PATTACH_POINT, parent)
    				ParticleManager:SetParticleControl(nfx, 0, point)
    				ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, 0, 0))

    	self:AttachEffect(nfx)
		self.damage = self:GetAbility().lastDamageDealt * caster:FindTalentValue("special_bonus_unique_grimstroke_stroke_1") / 100

		self:StartIntervalThink(1)
    end
end

function modifier_grimstroke_stroke_spot:OnIntervalThink()
	local caster = self:GetCaster()
	for _, unit in ipairs( caster:FindEnemyUnitsInRadius( self.point, self.radius ) ) do
		self:GetAbility():DealDamage(caster, unit, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_grimstroke_stroke_spot:IsHidden()
	return true
end