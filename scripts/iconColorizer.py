import re
import sys
import argparse

from zipfile import ZipFile
from os import path, listdir, makedirs


COLORS = {"": "currentColor", "Red":"#C30000", "Blue": "#0067C5", "Green": "#06893A"}

def arg_getter():
    """
    Usage: ikonZipper.py [-h] files_path

    A program that takes a path and zips all svg-files to one zip-file.
    Output-file is by default named "ikoner.zip".

    Positional arguments:
        files_path    Path to svg-files to zip


    Optional arguments:
        -h, --help  show this help message and exit

        Returns:
                args:   Contains the input argument
    """
    args = argparse.ArgumentParser(description='A program that zips \
                                                svg-files on a given path.')

    args.add_argument('files_path', help='The path of the files to be zipped.')
    arg = args.parse_args()

    return arg


def get_files(in_path):
    files_to_zip = []
    try:
        for file in listdir(in_path):
            name, extension = path.splitext(file)
            if extension == ".svg":
                file_path = path.join(in_path, file)
                files_to_zip.append(file_path)
        return files_to_zip

    except FileNotFoundError:
        print("Folder not found. Check path.  'python3 zipper.py -h' for help \n")
        sys.exit()


def zip_files(files_to_zip, files_path):
    out_name = path.join(files_path, "ikoner.zip")

    if not files_to_zip:
        print(f"No svg-files in path {files_path} \n")
        return

    zipper = ZipFile(out_name, "w")

    for file in files_to_zip:
        colorized_files = generate_colorized(file)

        for colorized_file in colorized_files:
            relative_path = "/".join(colorized_file.split("/")[-2:])
            zipper.write(colorized_file, relative_path)
    print(f"{zipper.filename} was saved")
    zipper.close()


def generate_colorized(filename):
    name = path.splitext(path.basename(filename))[0]
    out_path = path.splitext(filename)[0]
    color_files = []
    with open(filename, "r") as file:
        output_string = file.read()

    for color in COLORS.keys():
        print(color)
        output = output_string.replace("<svg", f'<svg id="{name}{color}"')
        new_filename = f"{out_path}/{name}{color}.svg"

        output_path = re.findall("(?<=<path)(.*)", output)[0]

        new_output_path = re.sub('(?<=fill=")(.*)(")', f'{COLORS[color]}"', output_path)
        output = output.replace(output_path, new_output_path)

        makedirs(path.dirname(new_filename), exist_ok=True)
        out = open(new_filename, "w")
        out.write(output)
        out.close()
        color_files.append(new_filename)

    return color_files


def main():
    arguments = arg_getter()
    files_path = arguments.files_path
    files_to_zip = get_files(files_path)
    zip_files(files_to_zip, files_path)


if __name__ == "__main__":
    main()

