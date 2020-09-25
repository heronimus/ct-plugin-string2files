module filewriter

import os

fn (mut fw FileWriter) write_ofile() {
	if fw.is_newline {
		fw.ofile.writeln(fw.content)
		return
	}
	fw.ofile.write(fw.content)
}

fn (mut fw FileWriter) create_dir() {
	dir := os.dir(fw.path)
	if !os.is_dir(dir) {
		fw.logger.info("directory not exist, creating '$dir'.")
		os.mkdir_all(dir)
		if !os.is_dir(dir) {
			fw.logger.fatal("directory not created: '$dir'.")
		}
	}
}
