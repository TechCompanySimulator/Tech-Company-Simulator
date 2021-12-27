return function()
	beforeAll(function()
		warn("Shared tests started")
	end)

	afterAll(function()
		warn("Shared tests complete")
	end)
end