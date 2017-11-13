weaver_timelapse_ebf = class({})

function weaver_timelapse_ebf:GetIntrinsicModifierName()
	return "weaver_timelapse_ebf_checker"
end

HEALTH_INDEX = 1
MANA_INDEX = 2
POSITION_INDEX = 3

if IsServer() then
	function weaver_timelapse_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local allies = FindUnitsInRadius(caster:GetTeam(),
                                    caster:GetAbsOrigin(),
                                    nil,
                                    self:GetSpecialValueFor("tooltip_range"),
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_DEAD,
                                    FIND_ANY_ORDER,
                                    false)
		for _, ally in pairs(allies) do
			if self.tempList[ally:entindex()] and self.tempList[ally:entindex()][1][HEALTH_INDEX] then
				local health = self.tempList[ally:entindex()][1][HEALTH_INDEX]
				local mana = self.tempList[ally:entindex()][1][MANA_INDEX]
				local position = self.tempList[ally:entindex()][1][POSITION_INDEX]

				particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN  , ally)
				ParticleManager:SetParticleControl(particle_ground, 0, ally:GetAbsOrigin())
				if ally ~= self:GetCaster() then
					if health > ally:GetHealth() and ally:IsAlive() then
						ally:SetHealth(health)
					elseif health > ally:GetHealth() and not ally:IsAlive() then
						local origin = ally:GetOrigin()
						ally:RespawnHero(false, false)
						ally:SetOrigin(origin)
						ally:SetHealth(health)
					end
					ally:Purge(false,true,false,true,false)
					ParticleManager:SetParticleControl(particle_ground, 1, ally:GetAbsOrigin()) --radius
					ParticleManager:SetParticleControl(particle_ground, 2, ally:GetAbsOrigin()) --ammount of particle
				else
					ally:SetHealth(health)
					ally:SetMana(mana)
					ally:Interrupt()
					ally:Purge(false,true,false,true,false)
					ProjectileManager:ProjectileDodge(ally)
					FindClearSpaceForUnit(ally, position, true)
					ParticleManager:SetParticleControl(particle_ground, 1, position) --radius
					ParticleManager:SetParticleControl(particle_ground, 2, position) --ammount of particle
				end
				EmitSoundOn("Hero_Weaver.TimeLapse", caster)
				ParticleManager:ReleaseParticleIndex(particle_ground)
			end
		end
	end
end

LinkLuaModifier( "weaver_timelapse_ebf_checker", "lua_abilities/heroes/weaver.lua" ,LUA_MODIFIER_MOTION_NONE )
weaver_timelapse_ebf_checker = class({})

function weaver_timelapse_ebf_checker:OnCreated()
	self.backtrack_time = 5.0
	self.remember_interval = 0.2
	self.maxindex = self.backtrack_time / self.remember_interval
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function weaver_timelapse_ebf_checker:IsHidden()
	return true
end
	
if IsServer() then
	function weaver_timelapse_ebf_checker:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		-- Temporary damage array and index
		if not ability.tempList then  ability.tempList = {} end
		local allies = FindUnitsInRadius(caster:GetTeam(),
										caster:GetAbsOrigin(),
										nil,
										9999,
										DOTA_UNIT_TARGET_TEAM_FRIENDLY,
										DOTA_UNIT_TARGET_HERO,
										DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_DEAD,
										FIND_ANY_ORDER,
										false)
		for _,ally in pairs(allies) do
			if not ability.tempList[ally:entindex()] then ability.tempList[ally:entindex()] = {} end
			local allyTable = {}
			allyTable[HEALTH_INDEX] = ally:GetHealth()
			allyTable[MANA_INDEX] = ally:GetMana()
			allyTable[POSITION_INDEX] = ally:GetAbsOrigin()
			table.insert(ability.tempList[ally:entindex()],allyTable)
		end
		for _,ally in pairs(allies) do
			if #ability.tempList[ally:entindex()] > self.maxindex then
				table.remove(ability.tempList[ally:entindex()],1)
			end
		end
	end
end