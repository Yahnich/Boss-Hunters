function ReflectDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local damageTaken = keys.damage
	local reflect_pct = ability:GetTalentSpecialValueFor("reflect_pct")/100
	
	-- Check if it's not already been hit
	if not attacker:IsMagicImmune() then
		attacker:SetHealth( attacker:GetHealth() - damageTaken*reflect_pct )
		if attacker:GetHealth() < 1 then
			attacker:SetHealth(1)
			attacker:ForceKill(true)
		end
		caster:SetHealth( caster:GetHealth() + damageTaken*reflect_pct )
	end
end

function ScepterTauntEffect(keys)
	local caster = keys.caster
	local target = keys.target
	local order = {
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = caster:entindex() }
	ExecuteOrderFromTable(order)
end

function DodgeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	caster:SetHealth( caster.oldHealth )
end

function ScepterHandlingDodge(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasScepter() and caster:HasModifier("modifier_nyx_assassin_burrow") then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_untouchable_scepter", { duration = ability:GetTalentSpecialValueFor("duration") } )
		caster.oldHealth = caster:GetHealth()
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_untouchable", { duration = ability:GetTalentSpecialValueFor("duration") } )
	end
end

function ScepterHandlingCarapace(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasScepter() and caster:HasModifier("modifier_nyx_assassin_burrow") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_nyx_carapace_taunt", {duration = 0.1}) -- particles
		caster.burrowAbility =  caster.burrowAbility or caster:FindAbilityByName("nyx_assassin_burrow")
		local radius = caster.burrowAbility:GetTalentSpecialValueFor("carapace_burrow_range_tooltip")
		local units = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                              FIND_ANY_ORDER,
                              false)
		for _,unit in pairs(units) do
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_nyx_carapace_taunt_target", {duration = ability:GetDuration()})
        end
		EmitSoundOn("Hero_NyxAssassin.SpikedCarapace.Stun", caster)
	else
		EmitSoundOn("Hero_NyxAssassin.SpikedCarapace", caster)
	end
end


