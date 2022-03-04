from io import TextIOWrapper
import os
import sys
import os.path
from typing import *
from tempfile import NamedTemporaryFile
import subprocess
import hashlib
from collections import defaultdict

dir = os.path.dirname(os.path.realpath(__file__))

MARKER = "void main(void) { mainImage(fragColor,gl_FragCoord.xy); }"
WIDTH = 640
HEIGHT = 320
FRAMERATE = 20


def shell(cmd: str) -> bool:
    print(cmd)
    result = subprocess.run(
        cmd, stderr=sys.stderr, stdout=sys.stdout, cwd=dir, shell=True
    )
    return result.returncode == 0


def file_hash(path: str) -> str:
    with open(path, mode='rb') as f:
        return hashlib.md5(f.read()).hexdigest()


class CSV:
    def __init__(self, path: str) -> None:
        self.path = path
    
    def __iter__(self):
        self.fd = open(self.path)
        self.i = iter(self.fd)
        return self
    
    def __next__(self):
        try:
            line = next(self.i).strip()
            if len(line) > 0:
                return line.split(",")
        except StopIteration:
            self.fd.close()
            raise StopIteration


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
    if not shell("which gifsicle"):
        print("gifsicle not installed", file=sys.stderr)
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


def process_shader(path: str, output: str, time: int) -> bool:
    tmp_path = prepare_shader(path)
    return shell(
        " ".join(
            [
                "shady",
                f'-i "{tmp_path}"',
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
                "-f gif",
                "-",
                "|",
                "gifsicle",
                "--optimize=3",
                ">"
                f'"{output}"',
            ]
        )
    )


BASIC_CATEGORIES = {
    "uv": "UV coordinates",
    "texture": "Texture generation",
    "shape": "Basic shapes"
}

def process_basic():
    basic_dir = os.path.join(dir, "..", "basic")
    cache = defaultdict(lambda:None)
    cache_file = os.path.join(basic_dir, "preview",".cache")
    for name, hash in CSV(cache_file):
        cache[name] = hash
    with open(os.path.join(basic_dir, f"README.md"), mode="w") as readme:
        readme.write("# Basic shaders\n\n")
        current_category = None
        for name, category, time in CSV(os.path.join(dir, "basic.csv")):
            if category != current_category:
                readme.write(f"## {BASIC_CATEGORIES[category]}\n\n")
                current_category = category
            input_file = os.path.join(basic_dir, f"{name}.glsl")
            output_file = os.path.join(basic_dir, "preview", f"{name}.gif")
            print(name, "...")
            hash = file_hash(input_file)
            if cache[name] != hash or not os.path.exists(output_file):
                process_shader(input_file, output_file, time)
                cache[name] = hash
            readme.write(f"`{name}`\n![{name}.glsl](./preview/{name}.gif)\n\n")
    with open(cache_file, mode="w") as f:
        for name in cache:
            f.write(f"{name},{cache[name]}\n")

check_env()
process_basic()