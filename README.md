# Patched Caddy NixOS flake

Caddy's third-party plugins are installed by adding them as import in
`cmd/caddy/main.go` and compiling caddy. This can be done either using the
`xcaddy` utility as described [here](https://caddyserver.com/docs/build) in the
official docs or by creating a `main.go` file with the import and compiling with
`go build` manually. This process is outlined in the upstream
[here](https://github.com/caddyserver/caddy/blob/82c356f2548ca62b75f76104bef44915482e8fd9/cmd/caddy/main.go#L21-L25).
The `xcaddy` utility is not suited for deployment on NixOS where a sandboxed,
reproducible build is required.

This flake compiles caddy from a custom `main.go` file as outlined above.
Currently adding the popular [caddy-security](https://authp.github.io/) as an
example. The `caddy` package of this flake's  output will be caddy with that
plugin baked in.

To modify/add plugins:

1. Edit `caddy-src/main.go` as per the upstream docs
2. Run `go mod tidy`
3. If necessary, update the hash in `flake.nix`
4. Run `nix build`

You should get a result with the compiled caddy. To verify that the plugins
where correctly added use:

```
./result/bin/caddy list-modules  
```
