druid_spirit_link = class({})
LinkLuaModifier("modifier_druid_spirit_link", "heroes/hero_lone_druid/druid_spirit_link", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_druid_bear_entangle", "heroes/hero_lone_druid/druid_bear_entangle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_druid_bear_demolish", "heroes/hero_lone_druid/druid_bear_demolish" ,LUA_MODIFIER_MOTION_NONE )

function druid_spirit_link:IsStealable()
    return true
end

function druid_spirit_link:IsHiddenWhenStolen()
    return false
end

function druid_spirit_link:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_LoneDruid.SpiritLink.Cast", caster)

	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	local duration = self:GetTalentSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_druid_spirit_link", {Duration = duration})

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,ally in pairs(allies) do
		if ally:GetOwner() == caster and ally:GetUnitLabel() == "spirit_bear" then
			EmitSoundOn("Hero_LoneDruid.SpiritLink.Bear", ally)

			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			ally:AddNewModifier(caster, self, "modifier_druid_spirit_link", {Duration = duration})
		end
	end
end

modifier_druid_spirit_link = class({})
function modifier_druid_spirit_link:OnCreated(table)
	self.bouns_as = self:GetTalentSpecialValueFor("bonus_as")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		self.heal = self:GetTalentSpecialValueFor("health_gain")/100

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_buff_afterlink.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_ABSORIGIN, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		if caster:HasTalent("special_bonus_unique_druid_spirit_link_1") then
			self:StartIntervalThink(1)
		end

		if caster:HasTalent("special_bonus_unique_druid_spirit_link_2") then
			if not caster:HasModifier("modifier_druid_transform") then
				if caster:HasAbility("druid_bear_demolish") then
					caster:RemoveAbility("druid_bear_demolish")
				end
				if not caster:HasAbility("druid_bear_entangle") then
					caster:AddAbility("druid_bear_entangle"):SetLevel(1)
				end
			else
				if caster:HasAbility("druid_bear_entangle") then
					caster:RemoveAbility("druid_bear_entangle")
				end
				if not caster:HasAbility("druid_bear_demolish") then
					caster:AddAbility("druid_bear_demolish"):SetLevel(1)
				end
			end
		else
			if caster:HasAbility("druid_bear_entangle") then
				caster:RemoveAbility("druid_bear_entangle")
			end
			if caster:HasAbility("druid_bear_demolish") then
				caster:RemoveAbility("druid_bear_demolish")
			end
		end
	end
end

function modifier_druid_spirit_link:OnRefresh(table)
	self.bouns_as = self:GetTalentSpecialValueFor("bonus_as")
	if IsServer() then
		local caster = self:GetCaster()

		self.heal = self:GetTalentSpecialValueFor("health_gain")/100

		if caster:HasTalent("special_bonus_unique_druid_spirit_link_1") then
			self:StartIntervalThink(1)
		end

		if caster:HasTalent("special_bonus_unique_druid_spirit_link_2") then
			if not caster:HasModifier("modifier_druid_transform") then
				if caster:HasAbility("druid_bear_demolish") then
					caster:RemoveAbility("druid_bear_demolish")
				end
				if not caster:HasAbility("druid_bear_entangle") then
					caster:AddAbility("druid_bear_entangle"):SetLevel(1)
				end
			else
				if caster:HasAbility("druid_bear_entangle") then
					caster:RemoveAbility("druid_bear_entangle")
				end
				if not caster:HasAbility("druid_bear_demolish") then
					caster:AddAbility("druid_bear_demolish"):SetLevel(1)
				end
			end
		else
			if caster:HasAbility("druid_bear_entangle") then
				caster:RemoveAbility("druid_bear_entangle")
			end
			if caster:HasAbility("druid_bear_demolish") then
				caster:RemoveAbility("druid_bear_demolish")
			end
		end
	end
end

function modifier_druid_spirit_link:OnIntervalThink()
	local parent = self:GetParent()
	local heal = parent:GetMaxHealth() * 1/100

	parent:HealEvent(heal, self:GetAbility(), self:GetCaster(), false)
end

function modifier_druid_spirit_link:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_druid_spirit_link:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		if caster:HasAbility("druid_bear_entangle") then
			caster:RemoveAbility("druid_bear_entangle")
		end
		if caster:HasAbility("druid_bear_demolish") then
			caster:RemoveAbility("druid_bear_demolish")
		end
	end
end

function modifier_druid_spirit_link:OnTakeDamage(params)
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local attacker = params.attacker
		local damage = params.damage

		if attacker == parent then
			local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
			for _,ally in pairs(allies) do
				if ally ~= attacker and ally:HasModifier("modifier_druid_spirit_link") then
					local heal = damage * self.heal
					ally:HealEvent(heal, self:GetAbility(), caster, false)
				end
			end
		end
	end
end

function modifier_druid_spirit_link:GetModifierAttackSpeedBonus()
	return self.bouns_as
end

function modifier_druid_spirit_link:IsDebuff()
	return false
end

function modifier_druid_spirit_link:IsPurgable()
	return true
end