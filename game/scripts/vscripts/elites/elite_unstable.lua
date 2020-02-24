elite_unstable = class({})

function elite_unstable:GetIntrinsicModifierName()
	return "modifier_elite_unstable"
end

modifier_elite_unstable = class(relicBaseClass)
LinkLuaModifier("modifier_elite_unstable", "elites/elite_unstable", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_unstable:OnCreated()
		self.lifetime = self:GetSpecialValueFor("bramble_lifetime")
		self.delay = self:GetSpecialValueFor("bramble_rate")
		self:StartIntervalThink( 1 )
	end
	
	function modifier_elite_unstable:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster:PassivesDisabled() or not caster:IsAlive() then return end
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 1200)
		if not enemies then return end
		for _,unit in pairs(enemies) do
			if RollPercentage(20) then
				local location = unit:GetAbsOrigin() + RandomVector( 1200 )
				local rnd = RandomInt(1,100)
				if rnd > 33 and rnd < 66 then
					ability:ApplyAOE({particles = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",
									  location = location,
									  radius = 350,
									  damage = 200,
									  damage_type = DAMAGE_TYPE_MAGICAL,
									  delay = 2.5,
									  sound = "Hero_Enigma.Demonic_Conversion"})				
				elseif rnd < 33 then
					ability:ApplyAOE({particles = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf",
									  location = location,
									  radius = 150,
									  damage = 75,
									  damage_type = DAMAGE_TYPE_MAGICAL,
									  modifier = "modifier_elite_unstable_stun",
									  duration = 1,
									  delay = 2.5,
									  sound = "Hero_Enigma.Demonic_Conversion"})
				else
					ability:ApplyAOE({particles = "particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf",
									  location = location,
									  radius = 225,
									  damage = 140,
									  damage_type = DAMAGE_TYPE_MAGICAL,
									  modifier = "modifier_chill_generic",
									  stacks = 50,
									  duration = 3,
									  delay = 2.5,
									  sound = "Hero_Enigma.Demonic_Conversion"})
				end
			end
		end
	end
end

function modifier_elite_unstable:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_unstable:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end