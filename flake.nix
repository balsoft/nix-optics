{
	outputs = { self }: {
		lib = import ./default.nix;
		checks = builtins.deepSeq (import ./tests.nix self.lib) {};
	};
}
