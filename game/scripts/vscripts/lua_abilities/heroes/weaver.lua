weaver_timelapse_ebf = class({})

function weaver_timelapse_ebf:GetIntrinsicModifierName()
	return "weaver_timelapse_ebf_checker"
end

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
			if self.tempList[ally:GetUnitName()] then
				local health = self.tempList[ally:GetUnitName()][1]["health"]
				local mana = self.tempList[ally:GetUnitName()][1]["mana"]
				local position = self.tempList[ally:GetUnitName()][1]["position"]
				-- Adds damage to caster's current health
				particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN  , ally)
				ParticleManager:SetParticleControl(particle_ground, 0, ally:GetAbsOrigin())
				if ally ~= self:GetCaster() and self.tempList[ally:GetUnitName()][1]["health"] then
					if health > ally:GetHealth() and ally:IsAlive() then
						ally:SetHealth(health)
					elseif health > ally:GetHealth() and not ally:IsAlive() then
						local origin = ally:GetOrigin()
						ally:RespawnHero(false, false, false)
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
			if not ability.tempList[ally:GetUnitName()] then ability.tempList[ally:GetUnitName()] = {} end
			local allyTable = {}
			allyTable["health"] = ally:GetHealth()
			allyTable["mana"] = ally:GetMana()
			allyTable["position"] = ally:GetAbsOrigin()
			table.insert(ability.tempList[ally:GetUnitName()],allyTable)
		end
		if #ability.tempList[caster:GetUnitName()] > self.maxindex then
			for _,ally in pairs(allies) do
				table.remove(ability.tempList[ally:GetUnitName()],1)
			end
		end
	end
end