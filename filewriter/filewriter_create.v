module filewriter

import os

pub fn (mut fw FileWriter) create_file() {
	// check force-create directory
	if fw.is_force {
		fw.create_dir()
	}
	// create & write file
	fw.ofile = os.create(fw.path) or {
		fw.logger.error('error while create file: ${err}')
		exit(1)
	}
	defer {
		fw.ofile.close()
	}
	fw.write_ofile()
}
