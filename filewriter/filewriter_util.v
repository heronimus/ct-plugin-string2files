module filewriter

import os

fn (mut fw FileWriter) write_ofile() {
	if fw.is_newline {
		fw.ofile.writeln(fw.content) or {
			fw.logger.fatal("error while write content to '${fw.path}'.")
		}
		return
	}
	fw.ofile.write_string(fw.content) or {
		fw.logger.fatal("error while write content to '${fw.path}'.")
	}
}

fn (mut fw FileWriter) create_dir() {
	dir := os.dir(fw.path)
	if !os.is_dir(dir) {
		fw.logger.info("directory not exist, creating '${dir}'.")
		os.mkdir_all(dir) or { fw.logger.fatal("error while create dir: '${dir}'.") }
		if !os.is_dir(dir) {
			fw.logger.fatal("directory not created: '${dir}'.")
		}
	}
}
