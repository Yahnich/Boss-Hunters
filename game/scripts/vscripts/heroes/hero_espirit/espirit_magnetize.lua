espirit_magnetize = class({})
LinkLuaModifier( "modifier_magnetize", "heroes/hero_espirit/espirit_magnetize.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_magnetize_stone", "heroes/hero_espirit/espirit_magnetize.lua" ,LUA_MODIFIER_MOTION_NONE )

function espirit_magnetize:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Hero_EarthSpirit.Magnetize.Cast", caster)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetTalentSpecialValueFor("radius"), 0, 0))
    ParticleManager:ReleaseParticleIndex(nfx)

    if caster:HasTalent("special_bonus_unique_espirit_magnetize_1") then
    	caster:AddNewModifier(caster, self, "modifier_magnetize_stone", {Duration = self:GetTalentSpecialValueFor("duration")})
    end

    local stones = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
    for _,stone in pairs(stones) do
    	if stone:GetName() == "npc_dota_earth_spirit_stone" then
    		if not stone:HasModifier("modifier_magnetize_stone") then
    			local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, caster)
		    	ParticleManager:SetParticleControlEnt(nfx2, 0, stone, PATTACH_POINT_FOLLOW, "attach_hitloc", stone:GetAbsOrigin(), true)
		    	ParticleManager:SetParticleControlEnt(nfx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		   	 	ParticleManager:ReleaseParticleIndex(nfx2)

				stone:AddNewModifier(caster, self, "modifier_magnetize_stone", {Duration = self:GetTalentSpecialValueFor("rock_explosion_delay")})
			end
    	end
    end
    
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
    for _,enemy in pairs(enemies) do
    	local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, caster)
    	ParticleManager:SetParticleControlEnt(nfx2, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
    	ParticleManager:SetParticleControlEnt(nfx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
   	 	ParticleManager:ReleaseParticleIndex(nfx2)

    	enemy:AddNewModifier(caster, self, "modifier_magnetize", {Duration = self:GetTalentSpecialValueFor("duration")})
    end
end

modifier_magnetize = class({})

function modifier_magnetize:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_magnetize:OnRefresh(table)
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_magnetize:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()

	EmitSoundOn("Hero_EarthSpirit.Magnetize.Target.Tick", target)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetTalentSpecialValueFor("radius"), self:GetTalentSpecialValueFor("radius"), self:GetTalentSpecialValueFor("radius")))
    ParticleManager:ReleaseParticleIndex(nfx)

    local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
    for _,enemy in pairs(enemies) do
    	self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
    end

	local stones = caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
    for _,stone in pairs(stones) do
    	if stone:GetName() == "npc_dota_earth_spirit_stone" then
    		if not stone:HasModifier("modifier_magnetize_stone") then
				stone:AddNewModifier(caster, self:GetAbility(), "modifier_magnetize_stone", {Duration = self:GetTalentSpecialValueFor("rock_explosion_delay")})
			end
    	end
    end
end

modifier_magnetize_stone = class({})
function modifier_magnetize_stone:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_magnetize_stone:OnRefresh(table)
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_magnetize_stone:OnIntervalThink()
	local caster = self:GetCaster()
	local stone = self:GetParent()

	local talent = false

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_POINT_FOLLOW, stone)
	ParticleManager:SetParticleControl(nfx, 0, stone:GetAbsOrigin())
	ParticleManager:SetParticleControl(nfx, 0, stone:GetAbsOrigin())
	ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetTalentSpecialValueFor("radius"), self:GetTalentSpecialValueFor("radius"), self:GetTalentSpecialValueFor("radius")))
	ParticleManager:ReleaseParticleIndex(nfx)

	local stones = caster:FindFriendlyUnitsInRadius(stone:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
    for _,stone2 in pairs(stones) do
    	if stone2 == caster and caster:HasTalent("special_bonus_unique_espirit_magnetize_1") then
    		talent = true
    	end

    	if stone2:GetName() == "npc_dota_earth_spirit_stone" or talent then
    		if not stone2:HasModifier("modifier_magnetize_stone") then
    			local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, stone)
				ParticleManager:SetParticleControlEnt(nfx2, 0, stone2, PATTACH_POINT_FOLLOW, "attach_hitloc", stone2:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx2, 1, stone, PATTACH_POINT_FOLLOW, "attach_hitloc", stone:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx2)

				stone2:AddNewModifier(caster, self:GetAbility(), "modifier_magnetize_stone", {Duration = self:GetTalentSpecialValueFor("rock_explosion_delay")})
			end
    	end
    end

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
	for _,enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_magnetize") then
			local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, stone)
			ParticleManager:SetParticleControlEnt(nfx2, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(nfx2, 1, stone, PATTACH_POINT_FOLLOW, "attach_hitloc", stone:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(nfx2)

			self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_magnetize", {Duration = self:GetTalentSpecialValueFor("duration")})
		end
	end
end

function modifier_magnetize_stone:OnRemoved()
	if IsServer() then
		if self:GetParent() ~= self:GetCaster() then
			self:GetParent():ForceKill(false)
		end
	end
end