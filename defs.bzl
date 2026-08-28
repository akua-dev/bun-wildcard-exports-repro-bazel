def _bun_action_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".ok")
    bun = ctx.executable.bun if ctx.executable.bun else ctx.file.bun
    ctx.actions.run_shell(
        outputs = [out],
        inputs = ctx.files.srcs,
        tools = [bun],
        arguments = [bun.path, out.path],
        command = """
set -euo pipefail
BUN="$1"
OUT="$2"
export HOME="$(mktemp -d)"
export CI=1
for f in package.json; do
  if [ -e "$f" ]; then cp -L "$f" "$f.material"; mv "$f.material" "$f"; fi
done
"$BUN" install
echo "=== node_modules/wildcard-pkg ==="
ls -la node_modules/wildcard-pkg || true
echo "=== bun run script.ts ==="
"$BUN" run script.ts
touch "$OUT"
""",
        execution_requirements = {"no-remote-exec": "1", "requires-network": "1"},
    )
    return [DefaultInfo(files = depset([out]))]

_bun_action = rule(
    implementation = _bun_action_impl,
    attrs = {
        "bun": attr.label(allow_single_file = True, cfg = "exec", executable = True),
        "srcs": attr.label_list(allow_files = True),
    },
)

def bun_action(name, bun):
    _bun_action(
        name = name,
        bun = bun,
        srcs = native.glob(["**/*"], exclude = ["bazel-*/**", "bazel-*"]),
    )
