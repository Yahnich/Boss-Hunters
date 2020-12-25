relic_boiling_blood = class(relicBaseClass)

function relic_boiling_blood:OnCreated()
	if IsServer() then self:StartIntervalThink(1) end
end

function relic_boiling_blood:OnIntervalThink()
	local parent = self:GetParent()
	if not parent:IsAlive() then return end
	local enemies = parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 600 )
	for _, enemy in ipairs( enemies ) do
		ApplyDamage({victim = enemy, attacker = parent, damage = math.ceil(parent:GetMaxHealth() * 0.02), damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
	if #enemies > 0 and not self:GetParent():HasModifier("relic_ritual_candle") then ApplyDamage({victim = parent, attacker = parent, damage = math.floor(parent:GetHealth() * 0.015), damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }) end
end