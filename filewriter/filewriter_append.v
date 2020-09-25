module filewriter

import os

pub fn (mut fw FileWriter) append_file() {
	// check force-create directory and file
	if !os.is_file(fw.path) {
		fw.create_file()
		fw.logger.info("file not exist, creating '$fw.path'.")
		return
	}
	// open & append file
	fw.ofile = os.open_append(fw.path) or {
		fw.logger.error('error while opening file $fw.path for appending')
		exit(1)
	}
	defer {
		fw.ofile.close()
	}
	fw.write_ofile()
}
