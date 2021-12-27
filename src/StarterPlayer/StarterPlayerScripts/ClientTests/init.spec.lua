return function()
	beforeAll(function()
		warn("Client tests started")
	end)

	afterAll(function()
		warn("Client tests complete")
	end)
end