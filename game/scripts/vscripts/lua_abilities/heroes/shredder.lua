function InitDeath(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster.nearTrees = false
	if GridNav:IsNearbyTree(caster:GetAbsOrigin(), ability:GetCastRange(), false) then
		caster.nearTrees = true
		GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), ability:GetCastRange(), true)
	end
end

function StatLoss(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetTalentSpecialValueFor("duration")
	local damage = ability:GetTalentSpecialValueFor("whirling_damage")
	local damageType = ability:GetAbilityDamageType()
	
	if caster.nearTrees then
		damageType = DAMAGE_TYPE_PURE
	end
	local statLoss = math.abs(ability:GetTalentSpecialValueFor("stat_loss_pct") / 100)
	target.hpLoss = target:GetMaxHealth() * statLoss
	
	local armorLoss = math.floor(target:GetPhysicalArmorBaseValue() * statLoss + 0.5)
	
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage, damage_type = damageType, ability = keys.ability})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_bonesplitter_stat_loss_stacks_armor", {duration = duration})
	target:SetModifierStackCount("modifier_bonesplitter_stat_loss_stacks_armor", caster, armorLoss)
	if not target.BoneSplitted then
		local hpPct = target:GetHealthPercent() / 100
		target:SetMaxHealth(target:GetMaxHealth() - target.hpLoss)
		target:SetHealth( math.max(1, target:GetMaxHealth() * hpPct) )
		target.BoneSplitted = true
	end
end

function RevertStatLoss(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target.BoneSplitted = false
	target:SetMaxHealth(target:GetMaxHealth() + target.hpLoss)
end