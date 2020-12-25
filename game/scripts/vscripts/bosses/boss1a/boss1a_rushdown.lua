boss1a_rushdown = class({})

function boss1a_rushdown:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCursorPosition(), 250)
	return true
end

function boss1a_rushdown:OnSpellStart()
	local caster = self:GetCaster()
	local endPos = self:GetCursorPosition()
	-- run around like an idiot
	caster:Interrupt()
	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = endPos, 
	})
	caster:AddNewModifier( caster, self, "modifier_boss1a_rushdown_attack_thinker", {duration = CalculateDistance(caster, endPos)/self:GetSpecialValueFor("rush_speed")})
end


modifier_boss1a_rushdown_attack_thinker = class({})
LinkLuaModifier("modifier_boss1a_rushdown_attack_thinker", "bosses/boss1a/boss1a_rushdown.lua", 0)

function modifier_boss1a_rushdown_attack_thinker:OnCreated()
	self.ms = self:GetSpecialValueFor("rush_speed")
	if IsServer() then 
		self:OnIntervalThink()
		self:StartIntervalThink(self:GetParent():GetSecondsPerAttack()) 
	end
end

function modifier_boss1a_rushdown_attack_thinker:OnIntervalThink()
	local parent = self:GetParent()
	local enemies = FindUnitsInLine(parent:GetTeam(), parent:GetAbsOrigin(), parent:GetAbsOrigin() + parent:GetForwardVector() * parent:GetAttackRange(), nil, 175, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
	for _, enemy in ipairs(enemies) do
		ParticleManager:FireParticle("particles/bosses/boss1a/boss1a_rushdown.vpcf", PATTACH_POINT_FOLLOW, enemy)
		parent:PerformGenericAttack(enemy, true)
	end
end

function modifier_boss1a_rushdown_attack_thinker:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss1a_rushdown_attack_thinker:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_boss1a_rushdown_attack_thinker:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end