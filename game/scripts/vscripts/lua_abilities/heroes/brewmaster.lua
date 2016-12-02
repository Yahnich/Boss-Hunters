
function PrimalAvatarScaleUp(keys)
	local caster = keys.caster
	local size = caster:GetModelScale()
	local scale = keys.scale
	local modifier = keys.modifier
	if size < scale then
		caster:SetModelScale(size+0.1)
	else
		caster:RemoveModifierByName(modifier)
	end
end

function ResetScale(keys)
	local caster = keys.caster
	local reset = keys.reset
	caster:SetModelScale(reset)
end

function PrimalAvatarScaleDown(keys)
	local caster = keys.caster
	local size = caster:GetModelScale()
	local scale = keys.scale
	local modifier = keys.modifier
	if size > scale and not caster:HasModifier("modifier_ogre_magi_bloodlust") and not caster:HasModifier("modifier_black_king_bar_immune") then
		caster:SetModelScale(size-0.1)
	else
		caster:RemoveModifierByName(modifier)
	end
end

function PrimalAuraDamage(keys)
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = keys.damage, damage_type = DAMAGE_TYPE_PURE, ability = keys.ability })
end