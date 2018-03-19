item_dagger_of_escape = class({})

function item_dagger_of_escape:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
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
end
