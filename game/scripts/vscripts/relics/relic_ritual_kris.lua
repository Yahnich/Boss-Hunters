relic_ritual_kris = class(relicBaseClass)
function relic_ritual_kris:OnCreated()
	self:OnRefresh()
end

function relic_ritual_kris:OnRefresh()
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function relic_ritual_kris:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function relic_ritual_kris:GetModifierCriticalDamage(params)
	if self:RollPRNG(10) then
		if not params.attacker:HasModifier("relic_ritual_candle") then
			ApplyDamage({victim = params.attacker, attacker = params.attacker, damage = params.attacker:GetHealth() * 0.1, ability = params.ability, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS})
		end
		return 360
	end
end