return function()
	beforeAll(function()
		warn("Server tests started")
	end)

	afterAll(function()
		warn("Server tests complete")
	end)
end