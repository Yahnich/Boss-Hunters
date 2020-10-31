skywrath_flare = class({})

function skywrath_flare:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetTalentSpecialValueFor("radius")

	local tick_rate = self:GetTalentSpecialValueFor("tick_rate")
	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_SkywrathMage.MysticFlare.Cast", caster)

	

	CreateModifierThinker(caster, self, "modifier_skywrath_flare", {duration = duration, ignoreStatusAmp = true}, point, caster:GetTeam(), false)

	if caster:HasScepter() then
        local pointRando = point + ActualRandomVector(radius * 3, radius * 1.25)
        CreateModifierThinker(caster, self, "modifier_skywrath_flare", {duration = duration, ignoreStatusAmp = true}, pointRando, caster:GetTeam(), false)
    end
end

modifier_skywrath_flare = class({})
LinkLuaModifier( "modifier_skywrath_flare","heroes/hero_skywrath/skywrath_flare.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_skywrath_flare:OnCreated(table)
	self.tick_rate = self:GetTalentSpecialValueFor("tick_rate")
	self.damage = self:GetTalentSpecialValueFor("damage") / self:GetTalentSpecialValueFor("duration")
	self.radius = self:GetTalentSpecialValueFor("radius")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_skywrath_flare_1")
	self.talent1Pct = self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_flare_1") / 100
	self.talent1Dur = self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_flare_1", "duration")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_skywrath_flare_2")
	self.talent2Speed = self:GetCaster():FindTalentValue("special_bonus_unique_skywrath_flare_2")
	if IsServer() then
		EmitSoundOn("Hero_SkywrathMage.MysticFlare", self:GetParent())
		self:StartIntervalThink(self.tick_rate)
		
		self.point = self:GetParent():GetAbsOrigin()
		
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_POINT, self:GetParent() )
		ParticleManager:SetParticleControl( self.nfx, 1, Vector( self.radius, 30, self.tick_rate ) )
		if self.talent2 then
			local bolt = self:GetCaster():FindAbilityByName("skywrath_arcane")
			self.lastCursorTarget = bolt:GetCursorTarget()
			Timers:CreateTimer( function()
				if bolt then
					if bolt:GetCursorTarget() then
						self.lastCursorTarget = bolt:GetCursorTarget()
					end
					if self.lastCursorTarget and not self.lastCursorTarget:IsNull() then
						local direction = CalculateDirection( self.lastCursorTarget, self.point )
						local distance = CalculateDistance(self.lastCursorTarget, self.point )
						self.point = self.point + direction * math.min( distance, self.talent2Speed * FrameTime() )
						self:GetParent():SetAbsOrigin( self.point )
						ParticleManager:SetParticleControl( self.nfx, 0, self.point )
					end
				end
				if not self:IsNull() then
					return 0
				end
			end)
		end
	end
end

function modifier_skywrath_flare:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_SkywrathMage.MysticFlare", self:GetParent())
		ParticleManager:ClearParticle( self.nfx )
	end
end

function modifier_skywrath_flare:OnIntervalThink()
	print( self:GetRemainingTime(), "thinker" )
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
    for _,enemy in pairs(enemies) do
    	EmitSoundOn("Hero_SkywrathMage.MysticFlare.Target", enemy)
    	local damage =  ability:DealDamage(caster, enemy, self.damage * self.tick_rate / #enemies)
		if self.talent1 then
			local stacks = math.ceil(damage * self.talent1Pct)
			local modifier = enemy:AddNewModifier( caster, ability, "modifier_skywrath_flare_talent", {duration = self.talent1Dur} )
			if modifier then
				modifier:SetStackCount( modifier:GetStackCount() + stacks )
			end
		end
    end
end

function modifier_skywrath_flare:DeclareFunctions()
	if self:GetCaster():HasTalent("special_bonus_unique_skywrath_flare_2") then
		return {MODIFIER_EVENT_ON_TAKEDAMAGE}
	end
end

function modifier_skywrath_flare:OnTakeDamage( params )
	if params.unit == self:GetCaster() then
		local damage = params.original_damage
		local modifiedDuration = params.original_damage/(self.damage)
		self:SetDuration( self:GetRemainingTime() + modifiedDuration, false )
	end
end

modifier_skywrath_flare_talent = class({})
LinkLuaModifier( "modifier_skywrath_flare_talent","heroes/hero_skywrath/skywrath_flare.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_skywrath_flare_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_skywrath_flare_talent:GetModifierPreAttack_BonusDamage()
	return -self:GetStackCount()
end