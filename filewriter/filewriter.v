module filewriter

import os
import log

pub struct FileWriter {
mut:
	ofile      os.File
	logger     log.Log = log.Log{
	level: .info
}
pub mut:
	path       string
	content    string
	is_force   bool
	is_newline bool
}
