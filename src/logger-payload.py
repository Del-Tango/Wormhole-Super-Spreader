#!/usr/bin/python3
# SIGNATURE - init_project_wormhole()
log_file = '/tmp/pw.tmp'
file_path = __file__
date_format = "%d/%m/%Y %H:%M:%S"
try:
    import datetime
    import getpass
    now = datetime.datetime.now()
    formatted_now = now.strftime(now, date_format)
    user_name = getpass.getuser()
    msg = '[ {} ]: File ({}) was executed by ({}).'.format(
        formatted_now, file_path, user_name
    )
    with open(log_file, 'a') as lf:
        lf.write(msg)
except:
    pass

