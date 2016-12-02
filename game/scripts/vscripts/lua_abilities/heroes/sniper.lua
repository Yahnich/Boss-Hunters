function HeadShot(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage()/get_aether_multiplier(caster), damage_type = ability:GetAbilityDamageType(), ability = ability})
	if not ability.prng then ability.prng = 0 end
	if caster:HasScepter() then
		local chance = ability:GetSpecialValueFor("assassinate_chance_scepter")
		if chance+ability.prng > math.random(100) then
			local assassinate = caster:FindAbilityByName("sniper_assassinate")
			ability.prng = 0
			if assassinate:GetLevel() > 0 and assassinate:IsCooldownReady() then
				local cooldown = assassinate:GetCooldown(-1) * ability:GetSpecialValueFor("assassinate_passive_cooldown_scepter") * get_octarine_multiplier(caster) / 100
				caster:SetCursorCastTarget(target)
				assassinate:OnSpellStart()
				assassinate:StartCooldown(cooldown)
			end
		else
			ability.prng = ability.prng + 1
		end
	end
end