chaos_knight_reality_rift_ebf = class({})

function chaos_knight_reality_rift_ebf:IsStealable()
	return true
end

function chaos_knight_reality_rift_ebf:IsHiddenWhenStolen()
	return false
end

function chaos_knight_reality_rift_ebf:GetAOERadius()
	return self:GetCaster():FindTalentValue("special_bonus_unique_chaos_knight_reality_rift_2")
end

function chaos_knight_reality_rift_ebf:OnAbilityPhaseStart()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	
	local casterPos = self.caster:GetAbsOrigin()
	local targetPos = self.target:GetAbsOrigin()
	local vDir = CalculateDirection( targetPos, casterPos )
	self.endPos = casterPos + vDir * CalculateDistance(targetPos, casterPos) * RandomFloat(0.3, 0.7)
	EmitSoundOn("Hero_ChaosKnight.RealityRift", self.caster)
	
	
	self.FX = {}
	local oRiftFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_CUSTOMORIGIN, self.target)
	ParticleManager:SetParticleControlEnt(oRiftFX, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", casterPos, true)
	ParticleManager:SetParticleControlEnt(oRiftFX, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", targetPos, true)
	ParticleManager:SetParticleControl(oRiftFX, 2, self.endPos)
	ParticleManager:SetParticleControlOrientation(oRiftFX, 2, vDir, Vector(0,1,0), Vector(1,0,0))
	table.insert(self.FX, oRiftFX)
	
	local searchRadius = 450
	self.illusions = self.caster:FindFriendlyUnitsInRadius(self.caster:GetAbsOrigin(), searchRadius, {flag = DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED})
	for _, illusion in ipairs( self.illusions ) do
		if self.caster ~= illusion and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == self.caster:GetPlayerOwnerID() then
			illusion:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
			local iRiftFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_CUSTOMORIGIN, self.target)
			ParticleManager:SetParticleControlEnt(iRiftFX, 0, illusion, PATTACH_POINT_FOLLOW, "attach_hitloc", illusion:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iRiftFX, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", targetPos, true)
			ParticleManager:SetParticleControl(iRiftFX, 2, self.endPos)
			ParticleManager:SetParticleControlOrientation(iRiftFX, 2, vDir, Vector(0,1,0), Vector(1,0,0))
			table.insert(self.FX, iRiftFX)
		end
	end
	
	if self.caster:HasTalent("special_bonus_unique_chaos_knight_reality_rift_2") then
		local enemies = self.caster:FindEnemyUnitsInRadius(self.target:GetAbsOrigin(), self.caster:FindTalentValue("special_bonus_unique_chaos_knight_reality_rift_2"))
		for _, enemy in ipairs( enemies ) do
			if enemy ~= self.target then
				local tRiftFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_CUSTOMORIGIN, enemy)
				ParticleManager:SetParticleControlEnt(tRiftFX, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", targetPos, true)
				ParticleManager:SetParticleControlEnt(tRiftFX, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(tRiftFX, 2, self.endPos)
				ParticleManager:SetParticleControlOrientation(tRiftFX, 2, CalculateDirection(self.target, enemy), Vector(0,1,0), Vector(1,0,0))
				table.insert(self.FX, tRiftFX)
			end
		end
	end
	return true
end

function chaos_knight_reality_rift_ebf:OnAbilityPhaseInterrupted()
	for _, fx in ipairs(self.FX) do
		ParticleManager:ClearParticle(fx)
	end
	for _, illusion in ipairs( self.illusions ) do
		if self.caster ~= illusion and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == self.caster:GetPlayerOwnerID() then
			illusion:StopGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
		end
	end
	StopSoundOn("Hero_ChaosKnight.RealityRift", self.caster)
end

function chaos_knight_reality_rift_ebf:OnSpellStart()
	for _, fx in ipairs(self.FX) do
		ParticleManager:ReleaseParticleIndex(fx)
	end
	
	local duration = self:GetTalentSpecialValueFor("armor_duration") 
	
	FindClearSpaceForUnit(self.caster, self.endPos, true)
	FindClearSpaceForUnit(self.target, self.endPos, true)
	
	local vDir = CalculateDirection(self.caster, self.target)
	
	self.caster:FaceTowards(self.target:GetAbsOrigin())
	self.target:FaceTowards(self.caster:GetAbsOrigin())
	
	self.caster:MoveToTargetToAttack(self.target)
	self.target:AddNewModifier(self.caster, self, "modifier_chaos_knight_reality_rift_ebf", {duration = duration})
	
	for _, illusion in ipairs( self.illusions ) do
		if self.caster ~= illusion and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == self.caster:GetPlayerOwnerID() then
			FindClearSpaceForUnit(illusion, self.endPos, true)
			illusion:FaceTowards(self.target:GetAbsOrigin())
			illusion:MoveToTargetToAttack(self.target)
		end
	end
	
	if self.caster:HasTalent("special_bonus_unique_chaos_knight_reality_rift_2") then
		local enemies = self.caster:FindEnemyUnitsInRadius(self.target:GetAbsOrigin(), self.caster:FindTalentValue("special_bonus_unique_chaos_knight_reality_rift_2"))
		for _, enemy in ipairs( enemies ) do
			if enemy ~= self.target then
				FindClearSpaceForUnit(enemy, self.endPos, true)
				enemy:FaceTowards(self.caster:GetAbsOrigin())
				enemy:AddNewModifier(self.caster, self, "modifier_chaos_knight_reality_rift_ebf", {duration = duration})
			end
		end
	end
end

modifier_chaos_knight_reality_rift_ebf = class({})
LinkLuaModifier("modifier_chaos_knight_reality_rift_ebf", "heroes/hero_chaos_knight/chaos_knight_reality_rift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_chaos_knight_reality_rift_ebf:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_chaos_knight_reality_rift_2", "as")
end

function modifier_chaos_knight_reality_rift_ebf:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_chaos_knight_reality_rift_2", "as")
end

function modifier_chaos_knight_reality_rift_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_chaos_knight_reality_rift_ebf:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_chaos_knight_reality_rift_ebf:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_chaos_knight_reality_rift_ebf:GetEffectName()
	return "particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift_buff.vpcf"
end