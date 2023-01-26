behaviour("LimitRespawn")

__cached_actors = {}

function LimitRespawn:Start()
	GameEvents.onActorSpawn.AddListener(self, "OnActorSpawn")
	print('Script loaded!')
end

function LimitRespawn:ClosestSpawnPoint(actor)
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
	if not actor.isBot then
		return
	end
	if not __cached_actors[actor] then
		__cached_actors[actor] = true
		return
	end
	spawnPoint = LimitRespawn:ClosestSpawnPoint(actor)
	if not spawnPoint.isContested then
		return
	end
	capturePoint = spawnPoint.capturePoint
	actors = ActorManager.AliveActorsInRange(capturePoint.transform.position, capturePoint.captureRange)
	balance = 0
	for index, aux_actor in pairs(actors) do
		if aux_actor.team == actor.team then
			balance = balance + 1
		else
			balance = balance - 1
		end
	end
	if balance < 0 then
		actor.KillSilently()
	end
end
