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
		},
		rinkeby: {
			host: "127.0.0.1", // Connect to geth on the specified
			port: 8545,
			from: "0x67c682096817F932a62654ed195a8A02C9866664",
			network_id: 4,
			gas: 670000 // Gas limit used for deploys
		}
	}
}
