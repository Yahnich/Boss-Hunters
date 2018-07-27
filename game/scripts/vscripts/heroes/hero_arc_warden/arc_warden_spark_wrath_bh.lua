arc_warden_spark_wrath_bh = class({})
LinkLuaModifier( "arc_warden_spark_wrath_bh_thinker", "heroes/hero_arc_warden/arc_warden_spark_wrath_bh.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_arc_warden_spark_wrath_talent", "heroes/hero_arc_warden/arc_warden_spark_wrath_bh.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function arc_warden_spark_wrath_bh:IsStealable()
	return true
end

function arc_warden_spark_wrath_bh:IsHiddenWhenStolen()
	return false
end

function arc_warden_spark_wrath_bh:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    return cooldown
end

function arc_warden_spark_wrath_bh:OnAbilityPhaseStart()
	EmitSoundOn("Hero_ArcWarden.SparkWraith.Cast", self:GetCaster())
	return true
end

function arc_warden_spark_wrath_bh:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_arc_warden_spark_wrath_bh_2") then return "modifier_arc_warden_spark_wrath_talent" end
end

function arc_warden_spark_wrath_bh:OnTalentLearned()
	if self:GetCaster():HasTalent("special_bonus_unique_arc_warden_spark_wrath_bh_2") then 
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_arc_warden_spark_wrath_talent", {} )
	end
end

function arc_warden_spark_wrath_bh:OnSpellStart()
	self:Spark(self:GetCursorPosition())
end

function arc_warden_spark_wrath_bh:Spark(vLocation)
	local caster = self:GetCaster()
	local point = vLocation
	local team_id = caster:GetTeamNumber()
	EmitSoundOnLocationWithCaster(point, "Hero_ArcWarden.SparkWraith.Appear", caster)
	CreateModifierThinker(caster, self, "arc_warden_spark_wrath_bh_thinker", {}, point, team_id, false)
end

function arc_warden_spark_wrath_bh:OnProjectileHit( target, location )
	local caster = self:GetCaster()

	if target then
		EmitSoundOn("Hero_ArcWarden.SparkWraith.Damage", target)
		--self:Stun(target, self:GetTalentSpecialValueFor("ministun_duration"))
		target:Paralyze(self, caster, self:GetTalentSpecialValueFor("ministun_duration"))
		self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"))
		AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), self:GetTalentSpecialValueFor("wraith_vision_radius"), self:GetTalentSpecialValueFor("wraith_vision_duration"), true)
	end
end

arc_warden_spark_wrath_bh_thinker = class({})

function arc_warden_spark_wrath_bh_thinker:OnCreated(event)
	if IsServer() then
		EmitSoundOn("Hero_ArcWarden.SparkWraith.Loop", self:GetParent())
		local thinker = self:GetParent()
		self.startup_time = self:GetTalentSpecialValueFor("activation_delay")
		self.duration = self:GetTalentSpecialValueFor("duration")
		self.speed = self:GetTalentSpecialValueFor("speed")
		self.search_radius = self:GetTalentSpecialValueFor("radius")
		self.vision_radius = self:GetTalentSpecialValueFor("wraith_vision_radius")

		local thinker_pos = thinker:GetAbsOrigin()
		local startup_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_wraith.vpcf", PATTACH_WORLDORIGIN, thinker)
								ParticleManager:SetParticleControl(startup_particle, 0, thinker_pos)
								ParticleManager:SetParticleControl(startup_particle, 1, Vector(self.search_radius, self.search_radius, self.search_radius))
		self:AttachEffect(startup_particle)
		
		self:StartIntervalThink(self.startup_time)
	end
end

function arc_warden_spark_wrath_bh_thinker:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_ArcWarden.SparkWraith.Loop", self:GetParent())
	end
end

function arc_warden_spark_wrath_bh_thinker:OnIntervalThink()
	local thinker = self:GetParent()
	local caster = self:GetCaster()
	local thinker_pos = thinker:GetAbsOrigin()
	if self.startup_time ~= nil then
		self.startup_time = nil
		self.expire = GameRules:GetGameTime() + self.duration
		self:StartIntervalThink(self:GetTalentSpecialValueFor("think_interval"))
	elseif self.duration ~= nil then
		if GameRules:GetGameTime() > self.expire then
			self:Destroy()
		else
			local enemies = caster:FindEnemyUnitsInRadius(thinker_pos, self.search_radius, {order=FIND_CLOSEST})
			for _,enemy in pairs(enemies) do
				EmitSoundOn("Hero_ArcWarden.SparkWraith.Activate", thinker)
				self.duration = nil
				self.expire = nil
				self:StartIntervalThink(-1)
				local info = 
					{
					Target = enemy,
					Source = thinker,
					Ability = self:GetAbility(),	
					EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
					vSourceLoc = thinker_pos,
					bDrawsOnMinimap = false,
					iSourceAttachment = 1,
					iMoveSpeed = self.speed,
					bDodgeable = false,
					bProvidesVision = true,
					iVisionRadius = self.vision_radius,
					iVisionTeamNumber = caster:GetTeam(),
					bVisibleToEnemies = true,
					flExpireTime = nil,
					bReplaceExisting = false
					}
				ProjectileManager:CreateTrackingProjectile(info)
				self:Destroy()
				break
			end
		end
	end
end

function arc_warden_spark_wrath_bh_thinker:CheckState()
	if self.duration then
		return {[MODIFIER_STATE_PROVIDES_VISION] = true}
	end
	return nil
end

modifier_arc_warden_spark_wrath_talent = clas({})

if IsServer() then
	function modifier_arc_warden_spark_wrath_talent:OnCreated()
		self.interval = self:GetCaster():FindTalentValue("special_bonus_unique_arc_warden_spark_wrath_bh_2")
		self:StartIntervalThink(0)
	end
	
	function modifier_arc_warden_spark_wrath_talent:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:IsAlive() then
			self:GetAbility:Spark( caster:GetAbsOrigin() )
			self:StartIntervalThink(self.interval)
		else
			self:StartIntervalThink(0.1)
		end
	end
end