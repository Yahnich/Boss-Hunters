boss_treant_thornmaze = class({})

function boss_treant_thornmaze:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local thorns = self:GetSpecialValueFor("thorn_count")
	local radius = self:GetSpecialValueFor("spread_radius")
	local buffer = self:GetSpecialValueFor("grab_radius") + 64
	local thornsList = {}
	for i = 1, thorns do
		local newPosition = position + ActualRandomVector( radius, buffer )
		-- make sure this position isn't overlapping with another thorn this caster; just kind of has to work
		for _, thornPos in ipairs( thornsList ) do
			local distance = CalculateDistance( thornPos, newPosition )
			if distance < buffer then
				toMove = buffer - distance
				local direction = CalculateDirection( newPosition, thornPos )
				newPosition = newPosition + direction * toMove
			end
		end
		CreateModifierThinker(caster, self, "modifier_boss_treant_thornmaze_thorn", {}, newPosition, caster:GetTeam(), false)
		table.insert( thornsList, newPosition )
	end
	EmitSoundOn( "Hero_Treant.NaturesGrasp.Cast", caster )
end

modifier_boss_treant_thornmaze_thorn = class({})
LinkLuaModifier( "modifier_boss_treant_thornmaze_thorn", "bosses/boss_treants/boss_treant_thornmaze", LUA_MODIFIER_MOTION_NONE )


function modifier_boss_treant_thornmaze_thorn:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("grab_radius")
	if IsServer() then
		EmitSoundOn("Hero_Treant.NaturesGrasp.Spawn", self:GetParent())
		nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_bramble_root.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		self:AddEffect(nFX)
		self:StartIntervalThink(1)
	end
end

function modifier_boss_treant_thornmaze_thorn:OnIntervalThink()
	if self:GetCaster():IsAlive() then return end
	self:Destroy()
end

function modifier_boss_treant_thornmaze_thorn:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Treant.NaturesGrasp.Destroy", self:GetParent())
	end
end

function modifier_boss_treant_thornmaze_thorn:IsAura()
	return true
end

function modifier_boss_treant_thornmaze_thorn:GetModifierAura()
	return "modifier_boss_treant_thornmaze_debuff"
end

function modifier_boss_treant_thornmaze_thorn:GetAuraRadius()
	return self.radius
end

function modifier_boss_treant_thornmaze_thorn:GetAuraDuration()
	return 0.5
end

function modifier_boss_treant_thornmaze_thorn:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_treant_thornmaze_thorn:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_treant_thornmaze_thorn:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end


modifier_boss_treant_thornmaze_debuff = class({})
LinkLuaModifier("modifier_boss_treant_thornmaze_debuff", "bosses/boss_treants/boss_treant_thornmaze", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_treant_thornmaze_debuff:IsDebuff()
	return true
end

function modifier_boss_treant_thornmaze_debuff:OnCreated()
	self:OnRefresh()
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_boss_treant_thornmaze_debuff:OnRefresh()
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.damage = self:GetTalentSpecialValueFor("damage_per_second")
end

function modifier_boss_treant_thornmaze_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_boss_treant_thornmaze_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_treant_thornmaze_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end