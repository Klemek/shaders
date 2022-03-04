import os
import sys
import os.path
from typing import *
from tempfile import NamedTemporaryFile
import subprocess

dir = os.path.dirname(os.path.realpath(__file__))

MARKER = "void main(void) { mainImage(fragColor,gl_FragCoord.xy); }"
WIDTH = 480
HEIGHT = 320
FRAMERATE = 20


def shell(cmd: str) -> bool:
    print(cmd)
    result = subprocess.run(
        cmd, stderr=sys.stderr, stdout=sys.stdout, cwd=dir, shell=True
    )
    return result.returncode == 0


def check_env():
    if not shell("which shady"):
        print(
            "shady not installed, see https://github.com/polyfloyd/shady",
            file=sys.stderr,
        )
        sys.exit(1)
    if not shell("which ffmpeg"):
        print("ffmpeg not installed", file=sys.stderr)
        sys.exit(1)


def prepare_shader(path: str) -> str:
    # TODO prepend midi
    with open(os.path.join(dir, path)) as src:
        with NamedTemporaryFile(mode="w", delete=False) as dst:
            writing = False
            for line in src:
                if writing:
                    dst.write(line)
                elif MARKER in line:
                    writing = True
            return dst.name


def process_shader(path: str, time: int, output: str) -> bool:
    tmp_path = prepare_shader(path)
    return shell(
        " ".join(
            [
                "shady",
                f"-i {tmp_path}",
                "-ofmt rgb24",
                f"-g {WIDTH}x{HEIGHT}",
                f"-f {FRAMERATE}",
                "|",
                "ffmpeg",
                "-f rawvideo",
                "-pixel_format rgb24",
                f"-video_size {WIDTH}x{HEIGHT}",
                f"-framerate {FRAMERATE}",
                f"-t {time}",
                "-i -",
                f'-vf "fps={FRAMERATE},scale={WIDTH}:{HEIGHT}:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"',
                "-loop 0",
                "-y",
                output,
            ]
        )
    )


check_env()
process_shader("basic/base_uv.glsl", 1, "basic/preview/base_uv.gif")
process_shader("basic/circle_shape.glsl", 4, "basic/preview/circle_shape.gif")