broodmother_spawn_spiderlings_bh = class({})
LinkLuaModifier("modifier_broodmother_spawn_spiderlings_bh", "heroes/hero_broodmother/broodmother_spawn_spiderlings_bh", LUA_MODIFIER_MOTION_NONE)

function broodmother_spawn_spiderlings_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", caster)
	self:FireTrackingProjectile("particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 50)
end

function broodmother_spawn_spiderlings_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", hTarget)
		hTarget:AddNewModifier(caster, self, "modifier_broodmother_spawn_spiderlings_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_broodmother_spawn_spiderlings_bh = class({})
function modifier_broodmother_spawn_spiderlings_bh:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_broodmother_spawn_spiderlings_bh:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage")*0.5, {}, 0)
end

function modifier_broodmother_spawn_spiderlings_bh:OnRemoved()
    if IsServer() then
    	local caster = self:GetCaster()
    	EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", self:GetParent())
    	ParticleManager:FireParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_POINT, self:GetParent(), {})
    	for i=1,self:GetTalentSpecialValueFor("count") do
    		local position = self:GetParent():GetAbsOrigin() + ActualRandomVector(150, 50)
    		local spider = caster:CreateSummon("npc_dota_broodmother_spiderling", position, self:GetTalentSpecialValueFor("spider_duration"))
    		FindClearSpaceForUnit(spider, position, false)
    		spider:RemoveAbility("broodmother_poison_sting")
    		spider:RemoveAbility("broodmother_spawn_spiderite")
    		local percentD = self:GetTalentSpecialValueFor("spider_damage")/100
            local percentH = self:GetTalentSpecialValueFor("spider_health")/100
    		spider:SetBaseDamageMin(caster:GetBaseDamageMin() * percentD)
    		spider:SetBaseDamageMax(caster:GetBaseDamageMax() * percentD)
    		spider:SetBaseAttackTime(caster:GetSecondsPerAttack())
    		spider:SetMaxHealth(caster:GetMaxHealth() * percentH)
    		spider:SetHealth(caster:GetMaxHealth() * percentH)
    		spider:SetBaseMoveSpeed(caster:GetBaseMoveSpeed())

    		spider:AddAbility("broodmother_bite"):SetLevel(1)
    		
    	end
    end
end

function modifier_broodmother_spawn_spiderlings_bh:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf"
end