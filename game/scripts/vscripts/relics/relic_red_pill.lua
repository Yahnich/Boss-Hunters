relic_red_pill = class(relicBaseClass)

function relic_red_pill:OnCreated()
	if IsServer() then
		local fx = ParticleManager:CreateParticle("particles/items_fx/glyph.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(fx, 1, Vector( (self:GetParent():GetHullRadius() * 2 + 50) * self:GetParent():GetModelScale(), 1, 1) )
		self:AddEffect(fx)
	end
end

function relic_red_pill:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false,
			[MODIFIER_STATE_UNSLOWABLE] = true}
end

function relic_red_pill:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end