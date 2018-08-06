module.exports = {
	networks: {
		ganache_cli: {
			host: "127.0.0.1",
			port: 8545,
			network_id: "*" // Match any network id
		},
		ganache_gui: {
			host: "127.0.0.1",
			port: 7545,
			network_id: "*" // Match any network id
		}
	}
}
