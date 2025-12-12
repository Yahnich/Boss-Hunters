antimage_blink_bh = class ({})

function antimage_blink_bh:GetIntrinsicModifierName()
	return "modifier_antimage_blink_handler"
end

function antimage_blink_bh:GetManaCost( iLvl )
	if self:GetCaster():HasModifier("modifier_antimage_blink_talent") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function antimage_blink_bh:OnSpellStart()
	local caster = self:GetCaster()
	local tPosition = self:GetCursorPosition()
	
	local startPos = caster:GetAbsOrigin()
	local direction = CalculateDirection(tPosition, caster)
	local distance = math.min( math.max( self:GetSpecialValueFor("min_blink_range"), CalculateDistance(tPosition, caster) ), self:GetSpecialValueFor("blink_range") )
	local endPos = caster:GetAbsOrigin() + direction * distance
	EmitSoundOn("Hero_Antimage.Blink_out", caster)

	FindClearSpaceForUnit(caster, endPos, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	EmitSoundOn("Hero_Antimage.Blink_in", caster)
	
	if caster:HasTalent("special_bonus_unique_antimage_blink_2") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( startPos, caster:FindTalentValue("special_bonus_unique_antimage_blink_2") ) ) do
			caster:PerformAbilityAttack( enemy, false, self )
		end
	end
	
	caster:RemoveModifierByName("modifier_antimage_blink_talent")
end

modifier_antimage_blink_handler = class({})
LinkLuaModifier( "modifier_antimage_blink_handler", "heroes/hero_antimage/antimage_blink_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_blink_handler:OnCreated()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_antimage_blink_1")
end

function modifier_antimage_blink_handler:OnRefresh()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_antimage_blink_1")
end

function modifier_antimage_blink_handler:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_antimage_blink_handler:OnTakeDamage(params)
	if params.unit == self:GetParent() and self.talent1 then
		params.unit:AddNewModifier( params.unit, self:GetAbility(), "modifier_antimage_blink_talent", {} )
		self:GetAbility():EndCooldown()
	end
end

function modifier_antimage_blink_handler:IsHidden()
	return true
end

modifier_antimage_blink_talent = class({})
LinkLuaModifier( "modifier_antimage_blink_talent", "heroes/hero_antimage/antimage_blink_bh", LUA_MODIFIER_MOTION_NONE )