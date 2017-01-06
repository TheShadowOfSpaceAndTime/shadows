-- @author Starkkz

Transform = {}
Transform.__index = Transform
Transform.x, Transform.y, Transform.z = 0, 0, 0

-- @description: Creates a new transformation
function Transform:new()
	
	local Transform = setmetatable({}, Transform)
	
	self.Children = {}
	self:SetLocalRotation(0)
	
	return Transform
	
end

-- @description: Assigns a transform as a parent of another transform
function Transform:SetParent(Parent)
	
	if self.Parent then
		
		self.Parent.Children[ self.ID ] = nil
		
	end
	
	if Parent then
		
		self.ID = #Parent.Children + 1
		self.Parent = Parent
		
		Parent[ self.ID ] = self
		
	else
		
		self.ID = nil
		self.Parent = nil
		
	end
	
end

-- @description: Gets the parent transform of a transform
function Transform:GetParent()
	
	return self.Parent
	
end

-- @description: Tells the children that the transform has changed
function Transform:Change()
	
	self.HasChanged = true
	
	for ID, Child in pairs(self.Children) do
		
		Child:Change()
		
	end
	
end

-- @description: Sets the local rotation of a transform
function Transform:SetLocalRotation(Angle)
	
	while Angle < -180 do
		
		Angle = Angle + 360
		
	end
	
	while Angle > 180 do
		
		Angle = Angle - 360
		
	end
	
	if Angle ~= self.Rotation then
		
		self.Rotation = Angle
		self.Radians = math.rad(Angle)
		
		if Angle == 0 then
			
			self.Matrix = {
				
				{1, 0},
				{0, 1},
				
			}
			
			self.InverseMatrix = {
				
				{1, 0},
				{0, 1},
				
			}
			
		else
		
			local Cosine = math.cos(self.Radians)
			local Sine = math.sin(self.Radians)
			
			-- The transformation matrix
			self.Matrix = {
				
				{ Cosine, Sine },
				{ -Sine, Cosine },
				
			}
			
			local Secant = 1 / Cosine
			local Cosecant = 1 / Sine
			
			-- The inverse transformation matrix
			self.InverseMatrix = {
				
				{
					Secant + ( Secant / ( -Cosine * Cosecant - Sine * Secant ) ) * Sine * Secant,
					Cosecant / ( -Cosine * Cosecant - Sine * Secant ) * Sine * Secant
				},
				
				{
					-Secant / (-Cosine * Cosecant - Sine * Secant),
					-Cosecant / ( -Cosine * Cosecant - Sine * Secant )
				},
				
			}
			
		end
		
		self:Change()
		
	end
	
end

-- @description: Gets the local rotation of a transform
function Transform:GetLocalRotation()
	
	return self.Rotation
	
end

-- @description: Sets the rotation of a transform
function Transform:SetRotation(Angle)
	
	if self.Parent then
		
		Angle = Angle - self.Parent:GetRotation()
		
	end
	
	self:SetLocalRotation(Angle)
	
end

-- @description: Gets the rotation of a transform
function Transform:GetRotation()
	
	if self.Parent then
		
		local Rotation = self.Rotation + self.Parent:GetRotation()
		
		while Rotation < -180 do
			
			Rotation = Rotation + 360
			
		end
		
		while Rotation > 180 do
			
			Rotation = Rotation - 360
			
		end
		
		return Rotation
		
	end
	
	return self.Rotation
	
end

-- @description: Sets the local position of a transform
function Transform:SetLocalPosition(x, y, z)
	
	if x ~= self.x or y ~= self.y or ( z and z ~= self.z ) then
		
		if z then
			
			self.z = z
			
		end
		
		self.x, self.y = x, y
		self:Change()
		
	end
	
end

-- @description: Gets the local position of a transform
function Transform:GetLocalPosition()
	
	return self.x, self.y, self.z
	
end

-- @description: Sets the position of a transform
function Transform:SetPosition(x, y, z)
	
	if self.Parent then
		
		x, y, z = self.Parent:ToLocal(x, y, z)
		
	end
	
	self:SetLocalPosition(x, y, z)
	
end

-- @description: Gets the position of a transform
function Transform:GetPosition()
	
	if self.Parent then
		
		return self.Parent:ToWorld(self.x, self.y, self.z)
		
	end
	
	return self.x, self.y, self.z
	
end

-- @description: Transforms a point to world coordinates
function Transform:ToWorld(x, y, z)
	
	if self.Parent then
		
		return self.Parent:ToWorld( self.x + self.Matrix[1][1] * x + self.Matrix[1][2] * y, self.y + self.Matrix[2][1] * x + self.Matrix[2][2] * y, self.z + z )
		
	end
	
	return self.x + self.Matrix[1][1] * x + self.Matrix[1][2] * y, self.y + self.Matrix[2][1] * x + self.Matrix[2][2] * y, self.z + z
	
end

-- @description: Transforms a point to local coordinates
function Transform:ToLocal(x, y, z)
	
	if self.Parent then
		
		x, y = self.Parent:ToLocal(x, y, z)
		
	end
	
	x, y, z = x - self.x, y - self.y, z - self.z
	
	return self.InverseMatrix[1][1] * x + self.InverseMatrix[1][2] * y, self.InverseMatrix[2][1] * x + self.InverseMatrix[2][2] * y, z
	
end

-- @description: Transform a local angle to world
function Transform:ToWorldAngle(Angle)
	
	local Rotation = Angle + self:GetRotation()
	
	while Rotation < -180 do
		
		Rotation = Rotation + 360
		
	end
	
	while Rotation > 180 do
		
		Rotation = Rotation - 360
		
	end
	
	return Rotation
	
end

-- @description: Transform a world angle to local
function Transform:ToLocalAngle(Angle)
	
	local Rotation = Angle - self:GetRotation()
	
	while Rotation < -180 do
		
		Rotation = Rotation + 360
		
	end
	
	while Rotation > 180 do
		
		Rotation = Rotation - 360
		
	end
	
	return Rotation
	
end

return Transform