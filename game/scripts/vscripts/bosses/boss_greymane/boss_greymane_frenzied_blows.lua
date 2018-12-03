boss_greymane_frenzied_blows = class({})

function boss_greymane_frenzied_blows:OnAbilityPhaseStart()
	local origPos = self:GetCaster():GetAbsOrigin()
	ParticleManager:FireLinearWarningParticle( origPos, origPos + CalculateDirection( self:GetCursorPosition(), origPos ) * self:GetTrueCastRange(), self:GetSpecialValueFor("width") )
	return true
end

function boss_greymane_frenzied_blows:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_greymane_frenzied_blows", {duration = math.max(GridNav:FindPathLength(caster:GetAbsOrigin(), self:GetCursorPosition() ), self:GetTrueCastRange() ) / self:GetSpecialValueFor("speed") })
end

modifier_boss_greymane_frenzied_blows = class({})
LinkLuaModifier( "modifier_boss_greymane_frenzied_blows", "bosses/boss_greymane/boss_greymane_frenzied_blows", LUA_MODIFIER_MOTION_NONE )


function modifier_boss_greymane_frenzied_blows:OnCreated()
	local parent = self:GetParent()
	self.speed = self:GetSpecialValueFor("speed")
	if IsServer() then
		self.width = self:GetSpecialValueFor("width")
		local origPos = self:GetCaster():GetAbsOrigin()
		self.endPos = origPos + CalculateDirection( self:GetAbility():GetCursorPosition(), origPos ) * self:GetAbility():GetTrueCastRange()
		parent:MoveToPosition(self.endPos)
		self:StartIntervalThink( self:GetSpecialValueFor("attack_interval") )
	end
end

if IsServer() then	
	function modifier_boss_greymane_frenzied_blows:OnIntervalThink()
		local caster = self:GetCaster()
		local direction = caster:GetForwardVector()
		local attackFX = ParticleManager:CreateParticle("particles/bosses/boss_greymane/boss_greymane_frenzied_blows.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlForward(attackFX, 0, direction)
		ParticleManager:SetParticleControlForward(attackFX, 1, direction)
		ParticleManager:SetParticleControlForward(attackFX, 3, direction)
		ParticleManager:ReleaseParticleIndex( attackFX )
		caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 6 )
		
		local startPos = caster:GetAbsOrigin()
		caster:EmitSound("Hero_Pangolier.Swashbuckle")
		for _, enemy in ipairs( caster:FindEnemyUnitsInLine( startPos, startPos + direction * caster:GetAttackRange(), self.width ) ) do
			caster:PerformGenericAttack(enemy, true)
		end
	end
end

function modifier_boss_greymane_frenzied_blows:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_greymane_frenzied_blows:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_boss_greymane_frenzied_blows:GetModifierMoveSpeed_AbsoluteMin()
	return self.speed
end

function modifier_boss_greymane_frenzied_blows:IsHidden()
	return true
end