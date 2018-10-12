mag_charge = class({})
LinkLuaModifier( "modifier_mag_charge", "heroes/hero_magnus/mag_charge.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mag_charge_enemy", "heroes/hero_magnus/mag_charge.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mag_charge_attack", "heroes/hero_magnus/mag_charge.lua" ,LUA_MODIFIER_MOTION_NONE )

function mag_charge:IsStealable()
    return true
end

function mag_charge:IsHiddenWhenStolen()
    return false
end

function mag_charge:OnSpellStart()
	EmitSoundOn("Hero_Magnataur.Skewer.Cast", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mag_charge", {})
    if self:GetCaster():HasTalent("special_bonus_unique_mag_charge_2") then
   		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mag_charge_attack", {})
   	end
end

modifier_mag_charge = class({})
function modifier_mag_charge:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_skewer.vpcf", PATTACH_POINT_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_horn", parent:GetAbsOrigin(), true)
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent():GetAbsOrigin())
		self.distance = self:GetAbility():GetTrueCastRange()
		if parent:HasTalent("special_bonus_unique_mag_charge_1") then
			self.distance = CalculateDistance(self:GetAbility():GetCursorPosition(), parent)
		end

		self:StartMotionController()
	end
end

function modifier_mag_charge:DoControlledMotion()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if self.distance > 0 then
		self.distance = self.distance - 50
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), true)
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*50)

		local magnets = parent:FindFriendlyUnitsInRadius(parent:GetAbsOrigin(),self:GetTalentSpecialValueFor("radius"))
		for _,magnet in pairs(magnets) do
			if magnet:HasModifier("modifier_mag_magnet") then
				magnet:AddNewModifier(parent, ability, "modifier_mag_charge_enemy", {Duration = 0.1})
				magnet:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*200)
			end
		end

		local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(),self:GetTalentSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			
			enemy:AddNewModifier(parent, ability, "modifier_mag_charge_enemy", {Duration = 0.1})
			enemy:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*200)
		end
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(),self:GetTalentSpecialValueFor("radius")+200)
		for _,enemy in pairs(enemies) do
			FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), true)
			
			if parent:HasTalent("special_bonus_unique_mag_charge_1") then
				local duration = parent:FindTalentValue("special_bonus_unique_mag_charge_1")
				ability:Stun(enemy, duration)
				ability:StartDelayedCooldown(duration)
			end
			if parent:HasTalent("special_bonus_unique_mag_charge_2") then
				local damage = parent:GetStrength() * parent:FindTalentValue("special_bonus_unique_mag_charge_2") / 100
				ability:DealDamage( parent, enemy, damage )
			end
		end

		local magnets = parent:FindFriendlyUnitsInRadius(parent:GetAbsOrigin(),self:GetTalentSpecialValueFor("radius")+200)
		for _,magnet in pairs(magnets) do
			if magnet:HasModifier("modifier_mag_magnet") then
				FindClearSpaceForUnit(magnet, magnet:GetAbsOrigin(), true)
			end
		end
		self:StopMotionController(true)
	end
end

function modifier_mag_charge:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_mag_charge:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return funcs
end

function modifier_mag_charge:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end

function modifier_mag_charge:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
		self:GetParent():StartGesture(ACT_DOTA_MAGNUS_SKEWER_END)
		self:GetParent():RemoveModifierByName("modifier_mag_charge_attack")
	end
end

modifier_mag_charge_enemy = class({})
function modifier_mag_charge_enemy:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_Magnataur.Skewer.Target", self:GetParent())
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_mag_charge_enemy:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_mag_charge_enemy:OnIntervalThink()
	local parent = self:GetParent()
	self:GetAbility():DealDamage(self:GetCaster(), parent, self:GetTalentSpecialValueFor("damage"), {}, 0)
	self:StartIntervalThink(0.5)
end

function modifier_mag_charge_enemy:GetEffectName()
	return "particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf"
end

modifier_mag_charge_attack = class({})
function modifier_mag_charge_attack:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetParent():GetSecondsPerAttack())
	end
end

function modifier_mag_charge_attack:OnIntervalThink()
	local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), 200)
	for _,enemy in pairs(enemies) do
		self:GetParent():PerformAttack(enemy, true, true, true, false, false, false, true)
		break
	end
end

function modifier_mag_charge_attack:IsHidden()
	return true
end
