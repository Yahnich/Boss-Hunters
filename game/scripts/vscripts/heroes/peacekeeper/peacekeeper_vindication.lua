peacekeeper_vindication = class({})
LinkLuaModifier( "modifier_vindication", "heroes/hero_peacekeeper/peacekeeper_vindication.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vindication_ally", "heroes/hero_peacekeeper/peacekeeper_vindication.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_vindication:OnSpellStart()
	self.caster = self:GetCaster()
	self.cursorTar = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor("duration")

	if self.cursorTar:GetTeam() ~= self.caster:GetTeam() and not self.cursorTar:IsMagicImmune() then
		local units = FindUnitsInRadius(self.caster:GetTeam(),self.cursorTar:GetAbsOrigin(),nil,FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		for _,unit in pairs(units) do
			unit:RemoveModifierByName("modifier_vindication")
		end
		self.cursorTar:AddNewModifier(self.caster,self,"modifier_vindication",{Duration = self.duration})
		EmitSoundOn("Hero_TemplarAssassin.Meld",self.cursorTar)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_vindication_ally = class({})

function modifier_vindication_ally:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()

		self.move_speed = self:GetSpecialValueFor("move_speed")
	end
end

function modifier_vindication_ally:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_vindication_ally:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_vindication = class({})

function modifier_vindication:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()
		self.mainBaddie = self:GetParent()

		self.lifesteal = self:GetSpecialValueFor("lifesteal")/100

		local units = FindUnitsInRadius(self.caster:GetTeam(),self.mainBaddie:GetAbsOrigin(),nil,FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		for _,unit in pairs(units) do
			if unit == self.caster then
				unit:AddNewModifier(self.caster,self:GetAbility(),"modifier_vindication_ally",{Duration = self:GetAbility().duration})
			end
		end
	end
end

function modifier_vindication:GetEffectName()
	return "particles/econ/items/templar_assassin/templar_assassin_focal/templar_meld_focal_overhead.vpcf"
end

function modifier_vindication:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_vindication:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_vindication:OnTakeDamage( params )
	if IsServer() then
		if params.unit == self.mainBaddie then
			local damage = params.damage
			local attacker = params.attacker

			if attacker:GetTeam() == self.caster:GetTeam() then
				SendOverheadEventMessage(attacker:GetPlayerOwner(),OVERHEAD_ALERT_HEAL,attacker,damage*self.lifesteal,attacker:GetPlayerOwner())
				attacker:Heal(damage*self.lifesteal,attacker)

				local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(lifesteal)
			end
		end
	end
end

function modifier_vindication:OnDestroy()
	if IsServer() then
		local units = FindUnitsInRadius(self.caster:GetTeam(),self.mainBaddie:GetAbsOrigin(),nil,FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		for _,unit in pairs(units) do
			if unit:HasModifier("modifier_vindication_ally") then
				unit:RemoveModifierByName("modifier_vindication_ally")
			end
		end
	end
end
