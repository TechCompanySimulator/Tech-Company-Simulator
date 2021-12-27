return function()
	beforeAll(function()
		warn("Zenith server tests started")
	end)

	afterAll(function()
		warn("Zenith server tests complete")
	end)
end