require("projectile")


if ProjectileHandler == nil then
  print ( 'creating projectile manager' )
  ProjectileHandler = {}
  ProjectileHandler.__index = ProjectileHandler
  ProjectileHandler.__mode = 'v'
end

function ProjectileHandler:new( o )
  o = o or {}
  setmetatable( o, ProjectileHandler )
  return o
end

PROJECTILE_THINK = 0.03

function ProjectileHandler:start()
  ProjectileHandler = self
  self.projectiles = {}
  GameRules:GetGameModeEntity():SetThink("ProjectileThink", self, "projectileThinker", PROJECTILE_THINK)
end

function ProjectileManager:FrameTime()
	return PROJECTILE_THINK
end

function ProjectileHandler:ProjectileThink()
	if not GameRules:IsGamePaused() then
		for id, projectile in pairs( self.projectiles ) do
			local status, err, ret = pcall (projectile.ProjectileThink, projectile)
			if not status then
				print(err)
				projectile:Remove()
			end
			projectile.aliveTime = (projectile.aliveTime or 0) + FrameTime()
			projectile.distanceTravelled = (projectile.distanceTravelled or 0) + projectile:GetVelocity():Length2D() * PROJECTILE_THINK
			if (projectile.aliveTime and projectile.duration and projectile.aliveTime >= projectile.duration) or (projectile.distance and projectile.distanceTravelled and projectile.distance <= projectile.distanceTravelled) then
				local position = projectile:GetPosition()
				local status, err, ret = pcall(projectile.hitBehavior, projectile, nil, position)
				projectile:Remove()
			end
		end
	end
	return PROJECTILE_THINK
end

PROJECTILE_LINEAR = function(self)
	local position = self:GetPosition()
	local velocity = self:GetVelocity()
	if velocity.z > 0 then velocity.z = 0 end
	self:SetPosition( position + (velocity*FrameTime()) )
end

PROJECTILE_GRAVITY = 300

function ProjectileHandler:CreateProjectile(thinkBehavior, hitBehavior, data)
	local newProjectile = Projectile(thinkBehavior, hitBehavior, data)
	self.projectiles[newProjectile.uniqueProjectileID] = newProjectile
	return newProjectile
end

if not ProjectileHandler.projectiles then 
	ProjectileHandler:start() 
end