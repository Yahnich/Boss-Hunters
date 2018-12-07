item_tricksters_blade = class({})

function item_tricksters_blade:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	local ogPos = caster:GetAbsOrigin()
	
	local distance = CalculateDistance( targetPos, caster )
	local direction = CalculateDirection( targetPos, caster )
	if distance > self:GetSpecialValueFor("blink_range") then
		targetPos = caster:GetAbsOrigin() + direction * self:GetSpecialValueFor("blink_range")
	end
	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", caster)
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	FindClearSpaceForUnit(caster, targetPos, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", caster)
	
	local illusion = caster:ConjureImage( ogPos, self:GetSpecialValueFor("duration"), -(100 - self:GetSpecialValueFor("illu_outgoing_damage")), self:GetSpecialValueFor("illu_incoming_damage") - 100 )
	illusion:SetThreat( caster:GetThreat() )
	caster:SetThreat( 0 )
end



function item_tricksters_blade:GetIntrinsicModifierName()
	return "modifier_item_tricksters_blade"
end

modifier_item_tricksters_blade = class(itemBaseClass)
LinkLuaModifier("modifier_item_tricksters_blade", "items/item_tricksters_blade", LUA_MODIFIER_MOTION_NONE)

function modifier_item_tricksters_blade:OnCreated()
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_tricksters_blade:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			}
end

function modifier_item_tricksters_blade:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_item_tricksters_blade:GetModifierBonusStats_Agility()
	return self.agility
end