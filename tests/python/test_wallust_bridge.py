import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "home/rylai/scripts/wallust-studio"))

from wallust_bridge import generate_base_palette  # noqa: E402

FIXTURE = {"background": "#101010", "foreground": "#eeeeee", "cursor": "#eeeeee",
           **{f"color{i}": f"#0000{i:02x}" for i in range(16)}}
USER_TOML = 'backend = "fastresize"\npalette = "dark16"\n\n[templates]\nkitty = { template = "kitty-colors.conf", target = "~/.config/kitty/current-theme.conf" }\n'

FAKE_WALLUST = """#!/usr/bin/env bash
printf '%s\\n' "$@" > "{tmp}/argv"
cfg=""
prev=""
for a in "$@"; do
  if [ "$prev" = "-C" ]; then cfg="$a"; fi
  prev="$a"
done
[ -n "$cfg" ] && cp "$cfg" "{tmp}/used_config.toml"
if [ {write_output} -eq 1 ] && [ -n "$cfg" ]; then
  target=$(sed -n 's/.*target = "\\([^"]*\\)".*/\\1/p' "$cfg" | head -n1)
  cp "{tmp}/fixture.json" "$target"
fi
exit {exit_code}
"""


class GenerateBasePaletteTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = Path(self._tmp.name)
        self.addCleanup(self._tmp.cleanup)
        (self.tmp / "bin").mkdir()
        self.img = str(self.tmp / "wall.png")
        Path(self.img).write_bytes(b"")
        self.user_cfg = self.tmp / "user_wallust.toml"
        self.user_cfg.write_text(USER_TOML)
        old_path = os.environ.get("PATH", "")
        os.environ["PATH"] = f"{self.tmp / 'bin'}:{old_path}"
        self.addCleanup(os.environ.__setitem__, "PATH", old_path)
        self.make_fake_wallust()

    def make_fake_wallust(self, exit_code=0, write_output=True, uppercase=False):
        import json
        data = {k: (v.upper() if uppercase else v) for k, v in FIXTURE.items()}
        (self.tmp / "fixture.json").write_text(json.dumps(data))
        script = self.tmp / "bin" / "wallust"
        script.write_text(FAKE_WALLUST.replace("{tmp}", str(self.tmp))
                          .replace("{write_output}", "1" if write_output else "0")
                          .replace("{exit_code}", str(exit_code)))
        script.chmod(0o755)

    def read_argv(self):
        return (self.tmp / "argv").read_text().splitlines()

    def read_used_config(self):
        return (self.tmp / "used_config.toml").read_text()

    def test_returns_palette_from_isolated_run(self):
        self.assertEqual(generate_base_palette(self.img, self.user_cfg), FIXTURE)

    def test_runs_wallust_with_isolated_config_and_no_sequences(self):
        generate_base_palette(self.img, self.user_cfg)
        argv = self.read_argv()
        self.assertEqual(argv[:2], ["run", self.img])
        self.assertIn("-s", argv)
        self.assertIn("-n", argv)
        cfg = argv[argv.index("-C") + 1]
        self.assertNotEqual(Path(cfg).resolve(), self.user_cfg.resolve())

    def test_base_palette_keeps_user_settings_without_templates(self):
        generate_base_palette(self.img, self.user_cfg)
        used = self.read_used_config()
        self.assertIn('backend = "fastresize"', used)
        self.assertIn('palette = "dark16"', used)
        self.assertNotIn("kitty-colors.conf", used)

    def test_user_config_untouched(self):
        generate_base_palette(self.img, self.user_cfg)
        self.assertEqual(self.user_cfg.read_text(), USER_TOML)

    def test_wallust_failure_raises(self):
        self.make_fake_wallust(exit_code=1)
        with self.assertRaises(subprocess.CalledProcessError):
            generate_base_palette(self.img, self.user_cfg)

    def test_missing_output_raises(self):
        self.make_fake_wallust(write_output=False)
        with self.assertRaises(RuntimeError):
            generate_base_palette(self.img, self.user_cfg)

    def test_template_path_is_absolute_and_hex_lowercased(self):
        self.make_fake_wallust(uppercase=True)
        self.assertEqual(generate_base_palette(self.img, self.user_cfg), FIXTURE)
        self.assertRegex(self.read_used_config(), r'template = "/[^"]+palette\.json\.tmpl"')


if __name__ == "__main__":
    unittest.main()
