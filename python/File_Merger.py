# Script to merge files from 2 directories together
import shutil
import os

from datetime import date


def move_files(_files, src, dest, name_template):
    if file_context.__contains__(name_template):
        i = file_context[name_template]
    else:
        i = 1

    for _f in _files:
        _, ext = os.path.splitext(_f)
        new_file_name = os.path.join(dest, name_template + str(i) + ext)
        if os.path.isfile(new_file_name):
            # Destination exists...seek a new number
            while os.path.isfile(new_file_name):
                i += 1
                new_file_name = os.path.join(dest, name_template + str(i) + ext)
            print("Skipping existing files to new name - " + new_file_name)

        old_file_name = os.path.join(src, _f)
        # print(f"MOVE FILE - {old_file_name} >>-----TO----->> {new_file_name}")

        shutil.move(old_file_name, new_file_name)
        i += 1

    file_context[name_template] = i


def get_target(_dir):
    if not os.path.isdir(_dir):
        # Does not Exist create it
        print("Create new directory in target - " + _dir)
        os.mkdir(_dir)
    return _dir


def traverse(source, target):
    for root, dirs, files in os.walk(source, topdown=False):
        for file in files:
            file_name, ext = os.path.splitext(file)
            tokens = file_name.split(" - ")
            if len(tokens) < 2:
                er_msg = "UNABLE TO UNDERSTAND FILE " + file_name + "  IT WILL BE SKIPPED!!!"
                print(er_msg)
                errors.append(er_msg)
                continue
            prefix = tokens[0].strip()
            new_name_template = str(f"{prefix} - {date.today().isoformat()} - ")
            target_dir = get_target(os.path.join(target, prefix))
            move_files([file], root, target_dir, new_name_template)

        for name in dirs:
            _dir = os.path.join(root, name)
            _files = os.listdir(_dir)
            dir_len = len(_files)
            if dir_len > 0:
                new_name_template = str(f"{name} - {date.today().isoformat()} - ")
                target_dir = get_target(os.path.join(target, name))
                move_files(_files, _dir, target_dir, new_name_template)
            # Delete _dir
            else:
                print(f"{_dir} has {dir_len} files and will be removed...")
                os.rmdir(_dir)


src = input("Enter source directory: ")
tgt = input("Enter target directory: ")
file_context = {}
errors = []

traverse(src, tgt)
print("The following errors were logged...")
for msg in errors:
    print(msg)


