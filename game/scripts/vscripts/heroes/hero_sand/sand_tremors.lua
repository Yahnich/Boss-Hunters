sand_tremors = class({})
LinkLuaModifier("modifier_tremors", "heroes/hero_sand/sand_tremors.lua", 0)
LinkLuaModifier("modifier_tremors_enemy", "heroes/hero_sand/sand_tremors.lua", 0)

function sand_tremors:OnAbilityPhaseStart()
	EmitSoundOn("Ability.SandKing_Epicenter.spell", self:GetCaster())
	return true
end


function sand_tremors:OnAbilityPhaseInterrupted()
	StopSoundOn("Ability.SandKing_Epicenter.spell", self:GetCaster())
end

function sand_tremors:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_tremors", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_tremors = class({})
if IsServer() then
	function modifier_tremors:OnCreated()
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tremor_rate"))
		EmitSoundOn("Ability.SandKing_Epicenter", self:GetParent())
	end

	function modifier_tremors:OnIntervalThink()
		local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
		ParticleManager:ReleaseParticleIndex(nfx)
		StopSoundOn("Ability.SandKing_Epicenter", self:GetParent())
		EmitSoundOn("Ability.SandKing_Epicenter", self:GetParent())
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {})
		for _,enemy in pairs(enemies) do
			self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("sandstorm_damage"), {}, 0)
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_tremors_enemy", {Duration = self:GetSpecialValueFor("duration")})

			if caster:HasTalent("special_bonus_unique_sand_tremors_2") then
				if not enemy:HasModifier("modifier_knockback") then
					enemy:ApplyKnockBack(caster:GetAbsOrigin(), 0.5, 0.5, -250, 250, caster, self:GetAbility())
				end
			end
		end
	end
	
	function modifier_tremors:OnRemoved()
		StopSoundOn("Ability.SandKing_Epicenter", self:GetParent())
	end
	
	function modifier_tremors:OnDestroy()
		StopSoundOn("Ability.SandKing_Epicenter", self:GetParent())
	end
end

modifier_tremors_enemy = class({})
function modifier_tremors_enemy:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
            }
end

function modifier_tremors_enemy:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow_move")
end

function modifier_tremors_enemy:GetModifierAttackSpeedBonus_Constant()
    return self:GetTalentSpecialValueFor("slow_as")
end

function modifier_tremors_enemy:IsDebuff()
    return true
end