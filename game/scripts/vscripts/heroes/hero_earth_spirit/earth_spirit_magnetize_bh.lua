earth_spirit_magnetize_bh = class({})
LinkLuaModifier( "modifier_magnetize", "heroes/hero_earth_spirit/earth_spirit_magnetize_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_magnetize_stone", "heroes/hero_earth_spirit/earth_spirit_magnetize_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function earth_spirit_magnetize_bh:IsStealable()
	return true
end

function earth_spirit_magnetize_bh:IsHiddenWhenStolen()
	return false
end

function earth_spirit_magnetize_bh:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Hero_EarthSpirit.Magnetize.Cast", caster)
	
	local remnantRadius = self:GetSpecialValueFor("refresh_radius")
	local enemyRadius = self:GetSpecialValueFor("search_radius")
	local duration = self:GetSpecialValueFor("duration")
	
    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnetize.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 2, Vector(enemyRadius, 0, 0))
    ParticleManager:ReleaseParticleIndex(nfx)
    if caster:HasTalent("special_bonus_unique_earth_spirit_magnetize_bh_1") then
    	caster:AddNewModifier(caster, self, "modifier_magnetize", {Duration = duration})
    end
    local stones = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), remnantRadius, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
    for _,stone in pairs(stones) do
    	if stone:GetName() == "npc_dota_earth_spirit_stone" then
    		if not stone:HasModifier("modifier_magnetize_stone") then
    			local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, caster)
		    	ParticleManager:SetParticleControlEnt(nfx2, 0, stone, PATTACH_POINT_FOLLOW, "attach_hitloc", stone:GetAbsOrigin(), true)
		    	ParticleManager:SetParticleControlEnt(nfx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		   	 	ParticleManager:ReleaseParticleIndex(nfx2)
				EmitSoundOn( "Hero_EarthSpirit.Magnetize.StoneBolt", enemy )
				
				stone:AddNewModifier(caster, self, "modifier_magnetize_stone", {Duration = self:GetSpecialValueFor("rock_explosion_delay")})
			end
    	end
    end
    
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), enemyRadius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
    for _,enemy in pairs(enemies) do
    	local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, caster)
    	ParticleManager:SetParticleControlEnt(nfx2, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
    	ParticleManager:SetParticleControlEnt(nfx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
   	 	ParticleManager:ReleaseParticleIndex(nfx2)
		EmitSoundOn( "Hero_EarthSpirit.Magnetize.StoneBolt", enemy )
		
    	enemy:AddNewModifier(caster, self, "modifier_magnetize", {Duration = duration})
    end
end

modifier_magnetize = class({})

function modifier_magnetize:OnCreated(table)
	if IsServer() then
		self.counterFX = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/earth_spirit_magnetize_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(self.counterFX, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect( self.counterFX )
	end
	self:OnRefresh()
end

function modifier_magnetize:OnRefresh(table)
	self.remnantRadius = self:GetSpecialValueFor("refresh_radius")
	self.enemyRadius = self:GetSpecialValueFor("search_radius")
	self.tick = self:GetSpecialValueFor("tick_rate")
	self.damage = self:GetSpecialValueFor("damage") * self.tick
	self.duration = self:GetSpecialValueFor("duration")
	self.explodeDelay = self:GetSpecialValueFor("rock_explosion_delay")
	if IsServer() then
		self:StartIntervalThink(self.tick)
		ParticleManager:SetParticleControl(self.counterFX, 1, Vector( math.ceil( self:GetRemainingTime() ), 1, 1 ) )
	end
end

function modifier_magnetize:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	
	EmitSoundOn("Hero_EarthSpirit.Magnetize.Target.Tick", target)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 2, Vector(enemyRadius, enemyRadius, enemyRadius))
    ParticleManager:ReleaseParticleIndex(nfx)
	
	if caster ~= target then ability:DealDamage( caster, target, self.damage ) end

    local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self.enemyRadius, {})
    for _,enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_magnetize") and self:GetRemainingTime() > 0.1 then
			local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(nfx2, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(nfx2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(nfx2)

			enemy:AddNewModifier(caster, ability, "modifier_magnetize", {Duration = self:GetRemainingTime() - 0.03})
			EmitSoundOn( "Hero_EarthSpirit.Magnetize.StoneBolt", enemy )
		end
    end

	local stones = caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), self.remnantRadius, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
    for _,stone in pairs(stones) do
    	if stone:GetName() == "npc_dota_earth_spirit_stone" then
    		if not stone:HasModifier("modifier_magnetize_stone") then
				stone:AddNewModifier(caster, ability, "modifier_magnetize_stone", {Duration = self.explodeDelay})
				local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(nfx2, 0, stone, PATTACH_POINT_FOLLOW, "attach_hitloc", stone:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx2)
				EmitSoundOn( "Hero_EarthSpirit.Magnetize.StoneBolt", stone )
				
				local enemies = caster:FindEnemyUnitsInRadius(stone:GetAbsOrigin(), self.remnantRadius, {})
				for _,enemy in pairs(enemies) do
					local nfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion_bolt.vpcf", PATTACH_POINT_FOLLOW, target)
					ParticleManager:SetParticleControlEnt(nfx3, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx3, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx3)
					
					enemy:AddNewModifier(caster, ability, "modifier_magnetize", {Duration = self.duration})
					EmitSoundOn( "Hero_EarthSpirit.Magnetize.StoneBolt", enemy )
				end
			end
    	end
    end
	ParticleManager:SetParticleControl(self.counterFX, 1, Vector( math.ceil( self:GetRemainingTime() ), 1, 1 ) )
end

modifier_magnetize_stone = class(modifier_magnetize)
function modifier_magnetize_stone:OnRefresh(table)
	self.remnantRadius = self:GetSpecialValueFor("refresh_radius")
	self.enemyRadius = self:GetSpecialValueFor("refresh_radius")
	self.damage = self:GetSpecialValueFor("damage")
	self.explodeDelay = self:GetSpecialValueFor("rock_explosion_delay")
	if IsServer() then
		self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
	end
end

function modifier_magnetize_stone:OnIntervalThink()
	local target = self:GetParent()
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 2, Vector(enemyRadius, enemyRadius, enemyRadius))
    ParticleManager:ReleaseParticleIndex(nfx)
	ParticleManager:SetParticleControl(self.counterFX, 1, Vector( math.ceil( self:GetRemainingTime() ), 1, 1 ) )
end

function modifier_magnetize_stone:OnRemoved()
	if IsServer() then
		if self:GetParent():GetName() == "npc_dota_earth_spirit_stone" then
			self:GetParent():ForceKill(false)
		end
	end
end