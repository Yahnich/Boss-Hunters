antimage_blink_bh = class ({})

function antimage_blink_bh:OnSpellStart()
	local caster = self:GetCaster()
	local tPosition = self:GetCursorPosition()
	
	local startPos = caster:GetAbsOrigin()
	local direction = CalculateDirection(tPosition, caster)
	local distance = math.min( math.max( self:GetTalentSpecialValueFor("min_blink_range"), CalculateDistance(tPosition, caster) ), self:GetTalentSpecialValueFor("blink_range") )
	local endPos = caster:GetAbsOrigin() + direction * distance
	EmitSoundOn("Hero_Antimage.Blink_out", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster, {[0] = startPos})
	if caster:HasTalent("special_bonus_unique_antimage_blink_1") then
		local illusion = caster:ConjureImage( startPos, caster:FindTalentValue("special_bonus_unique_antimage_blink_1", "duration"), caster:FindTalentValue("special_bonus_unique_antimage_blink_1", "outgoing"), caster:FindTalentValue("special_bonus_unique_antimage_blink_1", "incoming"), nil, self, false )
		illusion:MoveToPositionAggressive(startPos)
	end
	FindClearSpaceForUnit(caster, endPos, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	EmitSoundOn("Hero_Antimage.Blink_in", caster)
	
	if caster:HasTalent("special_bonus_unique_antimage_blink_2") then
		caster:AddNewModifier(caster, self, "modifier_antimage_blink_talent", {duration = caster:FindTalentValue("special_bonus_unique_antimage_blink_2", "duration")})
	end
end

modifier_antimage_blink_talent = class({})
LinkLuaModifier( "modifier_antimage_blink_talent", "heroes/hero_antimage/antimage_blink_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_blink_talent:OnCreated()
	self.heal = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_blink_2")
end

function modifier_antimage_blink_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_antimage_blink_talent:GetModifierHealthRegenPercentage()
	return self.heal
end