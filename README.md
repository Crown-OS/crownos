# crownos

All CrownOS component repositories as Git submodules, side by side, with the
commands, conventions and agent skills to work on them together.

```sh
git clone https://github.com/Crown-OS/crownos.git
cd crownos
just setup crowndock       # crowndock and only the repositories it needs
just status
```

- [CONTRIBUTING.md](CONTRIBUTING.md) tells you how to set up, build and send a change.
- [CLAUDE.md](CLAUDE.md) (also `AGENTS.md`) gives the code and layout rules.
- `.claude/skills/` has the agent skills: work on a component, ship it in the
  ISO, release it.

Licensed under either of [Apache License 2.0](LICENSE-APACHE) or
[MIT](LICENSE-MIT) at your option.
