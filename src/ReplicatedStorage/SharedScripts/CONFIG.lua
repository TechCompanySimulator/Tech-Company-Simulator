local CONFIG = {
	RUN_SERVER_TESTS = false;
	RUN_CLIENT_TESTS = false;
	RUN_SHARED_TESTS = false;
	RUN_FRAMEWORK_TESTS = true;
	RESET_PLAYER_DATA = true;

	SET_ALL_TRUE = false;
}

if CONFIG.SET_ALL_TRUE then
	for index, _ in pairs(CONFIG) do
		CONFIG[index] = true;
	end
end

return CONFIG
