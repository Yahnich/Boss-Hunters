ss_ball_lightning = class({})
LinkLuaModifier( "modifier_ss_ball_lightning", "heroes/hero_storm_spirit/ss_ball_lightning" ,LUA_MODIFIER_MOTION_NONE )

function ss_ball_lightning:IsStealable()
    return true
end

function ss_ball_lightning:IsHiddenWhenStolen()
    return false
end

function ss_ball_lightning:GetManaCost(iLevel)
	local manaCost = self:GetSpecialValueFor("mana_cost_base") + self:GetSpecialValueFor("mana_cost_pct")/100 * self:GetCaster():GetMaxMana()
    return manaCost
end

function ss_ball_lightning:OnSpellStart()
	EmitSoundOn("Hero_StormSpirit.BallLightning", self:GetCaster())

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ss_ball_lightning", {Duration = 10})

    ProjectileManager:ProjectileDodge(self:GetCaster())
end

modifier_ss_ball_lightning = class({})
function modifier_ss_ball_lightning:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), parent:GetAbsOrigin())
		self.distance = CalculateDistance(self:GetAbility():GetCursorPosition(), parent:GetAbsOrigin())

		self.speed = self:GetSpecialValueFor("speed") * FrameTime()
		self.radius = self:GetSpecialValueFor("radius")
		local travel_cost_base = self:GetSpecialValueFor("travel_cost_base")
		local travel_cost_percent = self:GetSpecialValueFor("travel_cost_percent")/100 * caster:GetMaxMana()

		self.manaCost = travel_cost_base + travel_cost_percent

		self.hitUnits = {}

		self.damageGain = self:GetSpecialValueFor("damage")
		self.damage = 0

		self.previousPoint = parent:GetAbsOrigin()
		self.previousPointTalent = parent:GetAbsOrigin()

		self.manaDistance = 0
		self.talentDistance = 0

		EmitSoundOn("Hero_StormSpirit.BallLightning.Loop", parent)
		
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_ss_ball_lightning:OnIntervalThink()
	local parent = self:GetParent()
	if parent:GetMana() >= self.manaCost then
		if self.distance > 0 then
			local currentPoint = parent:GetAbsOrigin()

			self.distance = self.distance - self.speed

			parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*self.speed)

			if self.manaDistance >= 100 then
				self:GetAbility():SpendMana(self.manaCost)
				self.damage = self.damage + self.damageGain
				self.manaDistance = 0
				self.previousPoint = parent:GetAbsOrigin()
			else
				self.manaDistance = CalculateDistance(self.previousPoint, currentPoint)
			end

			if parent:HasTalent("special_bonus_unique_ss_ball_lightning_1") then
				if self.talentDistance >= parent:FindTalentValue("special_bonus_unique_ss_ball_lightning_1") then
					local ability = parent:FindAbilityByName("ss_static_remnant")
					if ability and ability:IsTrained() then
						ability:CreateRemnant()
					end
					self.talentDistance = 0
					self.previousPointTalent = parent:GetAbsOrigin()
				else
					self.talentDistance = CalculateDistance(self.previousPointTalent, currentPoint)
				end
			end

			GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self.radius, false)

			local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
			for _,enemy in pairs(enemies) do
				if not self.hitUnits[ enemy:entindex() ] then
				
					if parent:HasTalent("special_bonus_unique_ss_ball_lightning_2") then
						local ability = parent:FindAbilityByName("ss_overload")
						ability:AddOverloadStack()
					end

					self:GetAbility():DealDamage(parent, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)

					self.hitUnits[ enemy:entindex() ] = true
				end
			end
		else
			self:Destroy()
		end
	else
		self:Destroy()
	end
end

function modifier_ss_ball_lightning:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,}
	return state
end

function modifier_ss_ball_lightning:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return funcs
end

function modifier_ss_ball_lightning:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_ss_ball_lightning:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_StormSpirit.BallLightning.Loop", self:GetParent())
		ResolveNPCPositions( self:GetParent():GetAbsOrigin(), self:GetParent():GetHullRadius() * 2 )
		self.hitUnits = {}
	end
end

function modifier_ss_ball_lightning:IsDebuff()
	return false
end

function modifier_ss_ball_lightning:IsPurgable()
	return true
end