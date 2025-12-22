alchemist_berserk_potion = class({})

function alchemist_berserk_potion:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local projectile = "particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf"
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")

	self:FireTrackingProjectile(projectile, target, projectile_speed, { source = caster })

	-- sounds
	local sound = "Hero_Alchemist.BerserkPotion.Cast"
	EmitSoundOn(sound, caster)
end
function alchemist_berserk_potion:OnProjectileHit(target, position)
	local caster = self:GetCaster()

	if target then
		local sound = "Hero_Alchemist.BerkserkPotion.Target"
		EmitSoundOn(sound, target)

		target:AddNewModifier(caster, self, "modifier_alchemist_berserk_potion_ebf", { duration = self:GetSpecialValueFor("duration") })
	end
end

modifier_alchemist_berserk_potion_ebf = class({})