local EasyStore = {}
local CachedDatastores = {}

local DataStoreService = game:GetService("DataStoreService")

function EasyStore:SetData(DatastoreName : string, Key : any, Data : SharedTable)
	local Datastore = DataStoreService:GetDataStore(DatastoreName)
	
	local Attempts = 1
	
	if Key and Data then
		for Attempts=Attempts, 10 do
			local Success, SaveHash = pcall(DataStoreService.SetAsync, Key, Data)
			
			if Success then
				return SaveHash
			end
		end
		
		-- handle further errors here
	else
		warn("Invalid arguments provided, please provide both they key to save data to and data to save.")
	end
end

function EasyStore:UpdateData(DatastoreName : string, Key : any, Data : SharedTable)
	local Datastore = DataStoreService:GetDataStore(DatastoreName)

	local Attempts = 1

	if Key and Data then
		for Attempts=Attempts, 10 do
			local Success, Tuple = pcall(DataStoreService.SetAsync, Key, Data)

			if Success then
				return Tuple
			end
		end

		-- handle further errors here
	else
		warn("Invalid arguments provided, please provide both they key to save data to and data to save.")
	end
end

function EasyStore:GetData(DatastoreName : string, Key : any)
	local Datastore = DataStoreService:GetDataStore(DatastoreName)
	
	local Attempts = 1
	
	for Attempts=Attempts, 10 do
		local Success, Data = pcall(Datastore.GetAsync, Key)
		
		if Success then
			return Data
		end
	end
	
	-- handle further errors here
end

function EasyStore:RemoveData(DatastoreName : string, Key : any)
	local Datastore = DataStoreService:GetDataStore(DatastoreName)
	
	return Datastore:RemoveAsync(Key)
end

function EasyStore:GetDatastore(DatastoreName : string)
	if CachedDatastores[DatastoreName] then
		return CachedDatastores[DatastoreName]
	end
	local RealDatastore = DataStoreService:GetDataStore(DatastoreName)
	
	local Datastore = {}
	setmetatable(Datastore, {
		__index = function(key)
			return RealDatastore[key]
		end
	})
	
	Datastore.SetAsync = function(Key : any, Data : SharedTable)
		return EasyStore:SetData(DatastoreName, Key, Data)
	end
	Datastore.SetData = Datastore.SetAsync
	
	Datastore.GetAsync = function(Key : any)
		return EasyStore:GetData(DatastoreName, Key)
	end
	Datastore.GetData = Datastore.GetAsync
	
	Datastore.RemoveAsync = function(Key : any)
		return EasyStore:RemoveData(DatastoreName, Key)
	end
	Datastore.RemoveData =  Datastore.RemoveAsync
	
	Datastore.UpdateAsync = function(Key : any, Callback : any)
		return EasyStore:UpdateData(DatastoreName, Key, Callback)
	end
	
	CachedDatastores[DatastoreName] = Datastore
	
	return Datastore
end

function EasyStore:GetRawDatastore(DatastoreName : string)
	return DataStoreService:GetDataStore(DatastoreName)
end

return EasyStore
