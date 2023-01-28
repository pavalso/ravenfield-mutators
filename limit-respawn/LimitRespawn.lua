behaviour("LimitRespawn")

__cached_actors = {}

__player_weigth = 9999

function LimitRespawn:Start()
	__player_weigth = self.script.mutator.GetConfigurationInt('player-weigth')
	GameEvents.onActorSpawn.AddListener(self, "OnActorSpawn")
	print('Script loaded!')
end

function LimitRespawn:ClosestSpawnPoint(actor)
	-- Member function of the 'LimitRespawn' class. 
	-- It takes in a single parameter, 'actor', which represents an actor in the game. 
	-- The function finds the spawn point closest to the actor's current position 
	-- by comparing the distance between the actor's position and each spawn point owned by the actor's team. 
	-- The closest spawn point is returned as the output of the function.
	spp = ActorManager.GetSpawnPointsOwnedByTeam(actor.team)
	closest = nil
	distance = Mathf.Infinity
	for index, spawnPoint in pairs(spp) do
		aux_distance = Vector3.Distance(actor.position, spawnPoint.spawnPosition)
		if aux_distance < distance then
			closest = spawnPoint
			distance = aux_distance
		end
	end
	return closest
end

function LimitRespawn:OnActorSpawn(actor)
	-- If the spawned actor is not a bot return immediately
	if not actor.isBot then
		return
	end

	-- If is the first time the script sees an actor remember him and return immediately
	if not __cached_actors[actor] then
		__cached_actors[actor] = true
		return
	end

	-- As Ravenscript API doesn't provide a direct way of obtaining the actor spawn point (if spawned at one)
	-- the script needs to get the closest spawn point to the actor to approximately obtain it. 
	spawnPoint = LimitRespawn:ClosestSpawnPoint(actor)

	-- If the point is not contested return immediately
	if not spawnPoint.isContested then
		return
	end

	capturePoint = spawnPoint.capturePoint

	-- Get all the actors that are attacking or defending the point
	actors = ActorManager.AliveActorsInRange(capturePoint.transform.position, capturePoint.captureRange)

	-- Calculate the balance between teams, having into account that the actor team add while the other teams substracts
	balance = 0
	for index, aux_actor in pairs(actors) do
		actor_effect = 1
		if not aux_actor.isBot then
			actor_effect = __player_weigth
		end

		if aux_actor.team == actor.team then
			balance = balance + actor_effect
		else
			balance = balance - actor_effect
		end
	end

	-- If the point is in a tie or being captured kill silently the spawned bot
	if balance < 0 then
		actor.KillSilently()
		print('Avoided '..actor.name..' respawn at '..spawnPoint.name)
	end
end
