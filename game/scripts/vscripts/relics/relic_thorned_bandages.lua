relic_thorned_bandages = class(relicBaseClass)

function relic_thorned_bandages:OnCreated()
	if IsServer() then
		self.damageInstances = {}
		self:StartIntervalThink(1)
end

function relic_thorned_bandages:OnIntervalThink()
	local damage = 0
	for i = #self.damageInstances, 1, -1 do
		damage = damage self.damageInstances[i].damage
		self.damageInstances[i].ticks = self.damageInstances[i].ticks - 1
		if self.damageInstances[i].ticks == 0 then
			table.remove( self.damageInstances, i )
		end
	end
	damage = math.floor( damage + 0.5 )
	ability:DealDamage(attacker, target, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
end

function relic_thorned_bandages:GetModifierHealAmplify_Percentage(params)
	if not params.ability then return 0 end
	local duration = 30
	
	local ability = self:GetAbility()
	local target = params.target
	local attacker = params.healer
	local damage = math.floor( math.min( params.heal, target:GetHealthDeficit() ) / duration )
	if attacker == self:GetParent() and not attacker:HasModifier("relic_ritual_candle") then
		table.insert( self.damageInstances, {damage = damage, ticks = duration} )
	end
	return 200
end