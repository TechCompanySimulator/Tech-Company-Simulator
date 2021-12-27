return function()
	beforeAll(function()
		warn("Zenith shared tests started")
	end)

	afterAll(function()
		warn("Zenith shared tests complete")
	end)
end