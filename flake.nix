{
  outputs = _: {
    templates = {
      rust = {
        path = ./rust;
        description = "Rust development shell";
      };
      haskell = {
        path = ./haskell;
        description = "Haskell development shell";
      };
    };
  };
}
