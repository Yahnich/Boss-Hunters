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

function druid_spirit_link:OnUpgrade()
	for _, ally in ipairs( self:GetCaster():FindFriendlyUnitsInRadius( self:GetCaster():GetAbsOrigin(), -1 ) ) do
		ally:RemoveModifierByName("modifier_druid_spirit_link_buff")
	end
end

function druid_spirit_link:GetIntrinsicModifierName()
	return "modifier_druid_spirit_link"
end

modifier_druid_spirit_link = class({})
function modifier_druid_spirit_link:OnCreated()
	self:OnRefresh()
end

function modifier_druid_spirit_link:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_druid_spirit_link:IsDebuff()
	return false
end

function modifier_druid_spirit_link:IsPurgable()
	return false
end

function modifier_druid_spirit_link:IsAura()
	return true
end

function modifier_druid_spirit_link:GetAuraRadius()
	return self.radius
end

function modifier_druid_spirit_link:GetModifierAura()
	return "modifier_druid_spirit_link_buff"
end

function modifier_druid_spirit_link:GetAuraDuration()
	return 0.5
end

function modifier_druid_spirit_link:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_druid_spirit_link:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_druid_spirit_link:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_druid_spirit_link:GetAuraEntityReject(unit)
	return not ( unit == self:GetCaster() or unit:GetOwner() == self:GetCaster() )
end

function modifier_druid_spirit_link:IsHidden()
	return true
end

modifier_druid_spirit_link_buff = class({})
LinkLuaModifier( "modifier_druid_spirit_link_buff", "heroes/hero_lone_druid/druid_spirit_link" ,LUA_MODIFIER_MOTION_NONE )

function modifier_druid_spirit_link_buff:OnCreated(table)
	local caster = self:GetCaster()
	local parent = self:GetParent()
	self.bouns_as = self:GetTalentSpecialValueFor("bonus_as")
	if caster:HasTalent("special_bonus_unique_druid_spirit_link_1") then
		self.regen = caster:FindTalentValue("special_bonus_unique_druid_spirit_link_1")
	end
		
	if IsServer() then

		self.heal = self:GetTalentSpecialValueFor("health_gain")/100

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_buff_afterlink.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_ABSORIGIN, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		
		if parent ~= caster then
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
			local spiritLinkFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
									ParticleManager:SetParticleControlEnt(spiritLinkFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
									ParticleManager:SetParticleControlEnt(spiritLinkFX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
									ParticleManager:ReleaseParticleIndex(spiritLinkFX)
			self:AttachEffect( spiritLinkFX )
			caster.spiritBear = parent
			parent.loneDruid = caster
		end
	end
end

function modifier_druid_spirit_link_buff:OnIntervalThink()
	local parent = self:GetParent()

end

function modifier_druid_spirit_link_buff:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		caster.spiritBear = nil
		parent.loneDruid = nil
		if parent ~= caster then
			if caster:HasAbility("druid_bear_entangle") then
				caster:RemoveAbility("druid_bear_entangle")
			end
			if caster:HasAbility("druid_bear_demolish") then
				caster:RemoveAbility("druid_bear_demolish")
			end
		end
	end
end

function modifier_druid_spirit_link_buff:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				   MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
	return funcs
end


function modifier_druid_spirit_link_buff:OnTakeDamage(params)
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local attacker = params.attacker
		local damage = params.damage
		
		local heal = damage * self.heal
		if attacker == parent then
			if parent ~= caster and parent.loneDruid then
			parent.loneDruid:HealEvent(heal, self:GetAbility(), caster, false)
			elseif parent == caster and caster.spiritBear then
				caster.spiritBear:HealEvent(heal, self:GetAbility(), caster, false)
			end
		end
	end
end

function modifier_druid_spirit_link_buff:GetModifierAttackSpeedBonus_Constant()
	return self.bouns_as
end

function modifier_druid_spirit_link_buff:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_druid_spirit_link_buff:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_buff.vpcf"
end