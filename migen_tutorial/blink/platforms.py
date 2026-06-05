# platforms.py
import os
import argparse

EFINITY_PATH = "/Work/CAD/efinity/2024.2"
BUILD_DIR    = os.path.abspath("build/gateware")

def get_platform(name):
    if name == "colorlight_i9":
        from litex_boards.platforms import colorlight_i5
        return colorlight_i5.Platform(board="i9", revision="7.2", toolchain="trellis"), 25e6, "user_led_n", "top.bit"
    elif name == "ecb_t8":
        from board import ecb_t8_t113
        return ecb_t8_t113.Platform(), 33.333e6, "user_led_n", "outflow/top.hex"
    else:
        raise ValueError(f"Plataforma desconocida: {name}")

def load_bitstream(platform, platform_name, build_dir, bitstream):
    bitstream_file = f"{build_dir}/{bitstream}"
    if platform_name == "ecb_t8":
        os.system(
            f'{EFINITY_PATH}/bin/python3 {EFINITY_PATH}/pgm/bin/efx_pgm/ftdi_program.py '
            f'{bitstream_file} -m passive '
            f'-b "Generic Board Profile Using FT2232H" '
            f'--url ftdi://0x0403:0x6010/1'
        )
    else:
        prog = platform.create_programmer()
        prog.load_bitstream(bitstream_file)

def parse_args(choices=None):
    choices = choices or ["colorlight_i9", "ecb_t8"]
    parser = argparse.ArgumentParser()
    parser.add_argument("--platform", default="colorlight_i9", choices=choices)
    return parser.parse_args()